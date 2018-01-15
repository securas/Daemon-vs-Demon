extends Node

# Global constants
const GRAVITY = 1000
const TERMINAL_VEL = 400


var score = 0 setget _update_score
var has_key = false setget _update_key
var boss_fight = false

#---------------------------
# act specific
#---------------------------
enum ACTS { HELL, GRAVEYARD }
var act_specific = {
	ACTS.HELL : { "scene": 1, "persistent": [] },
	ACTS.GRAVEYARD : { "scene": 1, "persistent": [] } }
var cur_act = ACTS.HELL

#---------------------------
# player info
#---------------------------
enum PLAYER_CHAR { HUMAN, HUMAN_SWORD, HUMAN_GUN, MONSTER_1, MONSTER_2, MONSTER_3, SATAN }
const CHAR_SCENES = { \
	PLAYER_CHAR.HUMAN: "res://scenes/player_human.tscn", \
	PLAYER_CHAR.HUMAN_SWORD: "res://scenes/player_sword.tscn", \
	PLAYER_CHAR.MONSTER_1: "res://scenes/player_monster_1.tscn", \
	PLAYER_CHAR.MONSTER_2: "res://scenes/player_monster_2.tscn", \
	PLAYER_CHAR.MONSTER_3: "res://scenes/player_monster_3.tscn", \
	PLAYER_CHAR.SATAN: "res://scenes/player_satan.tscn"  }

enum WEAPONS { NONE, SWORD, GUN }
var player = null
var player_spawnpos = Vector2()
var player_startpos = null
var player_char = PLAYER_CHAR.HUMAN#_SWORD
var continue_game = false


#---------------------------
# camera
#---------------------------
var camera
var camera_target = null
var camera_target_zoom = 1
#---------------------------
# main scene
#---------------------------
var main = null

#---------------------------
# pause control
#---------------------------
#var pause_timer = 0


#---------------------------
# control floor
#---------------------------
var floor_tilemap = null
var ground_tilemap = null



func _ready():
	
	set_pause_mode( Node.PAUSE_MODE_PROCESS )
	# main scene
	var _root = get_tree().get_root()
	main = _root.get_child( _root.get_child_count() - 1 )
	if main.get_name() != "main":
		main = null
#	set_fixed_process( true )


func reset_settings():
	player_char = PLAYER_CHAR.HUMAN
	act_specific = [ \
		{ "scene": 1, "persistent": [] }, \
		{ "scene": 1, "persistent": [] } ]



#func _fixed_process( delta ):
#	print( "spos: ", player_spawnpos )
#	
#	# hit Esc to quit
#	if Input.is_key_pressed( KEY_ESCAPE ):
#		get_tree().quit()



func _update_score( v ):
	score = v
	if main != null:
		main.score_nxt = score

func _update_key( v ):
	has_key = v
	if main != null:
		main.set_key( v )










func findweak( obj, arr ):
	for idx in range( arr.size() ):
		var aux = arr[idx].get_ref()
		if aux != null and aux == obj:
			return idx
	return -1



func check_fall_area( obj, pos ):
	if floor_tilemap == null or floor_tilemap.get_ref() == null:
		return _checkfalling_area( obj, pos )
	# first check tilemap
	var tilepos = floor_tilemap.get_ref().world_to_map( pos )
	if floor_tilemap.get_ref().get_cell( tilepos.x, tilepos.y ) == -1:
		return _checkfalling_area( obj, pos )
	return 0
	
	
func _checkfalling_area( obj, pos ):
	var space_state = obj.get_world_2d().get_direct_space_state()
	var results = space_state.intersect_point( pos, 32, [], 524288, 16 )
	if not results.empty():
		for r in results:
			if r.collider.is_in_group( "fall_area" ):
				if r.collider.is_in_group( "up_fall" ):
					return 1
				return -1
	return 0

func step_on_ground():
	if main == null: return
	if player!= null and player.get_ref() != null:
		var floor_type = _check_type_of_ground( player.get_ref().get_global_pos() )
		if floor_type == 1:
			pass
			main.play_sfx( "freesound.org_swuing__footstep-grass" )
		elif floor_type == 2:
			main.play_sfx( "freesound.org_swuing__footstep-grass" )
			pass

func _check_type_of_ground( pos ):
	if ground_tilemap == null or ground_tilemap.get_ref() == null:
		return 0
	var tilepos = ground_tilemap.get_ref().world_to_map( pos )
	var cur_cell = ground_tilemap.get_ref().get_cell( tilepos.x, tilepos.y )
	# check for hard ground tiles
	if cur_cell >= 6 and cur_cell <= 11:
		return 1 # hard ground
	return 2 # soft ground


func get_floor_at( gpos ):
	if floor_tilemap != null and floor_tilemap.get_ref() != null:
		var tile_coordinates = floor_tilemap.get_ref().world_to_map( gpos )
		return floor_tilemap.get_ref().get_cell( tile_coordinates.x, tile_coordinates.y )
	return -1