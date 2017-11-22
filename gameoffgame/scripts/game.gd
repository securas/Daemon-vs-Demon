extends Node

# Global constants
const GRAVITY = 1000
const TERMINAL_VEL = 400


var score = 0
var has_key = false
var boss_fight = false

#---------------------------
# act specific
#---------------------------
enum ACTS { HELL, GRAVEYARD }
var act_specific = {
	ACTS.HELL : { "scene": 1, "persistent": [] },
	ACTS.GRAVEYARD : { "scene": 2, "persistent": [] } }

#---------------------------
# player info
#---------------------------
enum PLAYER_CHAR { HUMAN, HUMAN_SWORD, HUMAN_GUN, MONSTER_1, MONSTER_2, MONSTER_3 }
const CHAR_SCENES = { \
	PLAYER_CHAR.HUMAN: "res://scenes/player_human.tscn", \
	PLAYER_CHAR.HUMAN_SWORD: "res://scenes/player_sword.tscn", \
	PLAYER_CHAR.MONSTER_1: "res://scenes/player_monster_1.tscn", \
	PLAYER_CHAR.MONSTER_2: "res://scenes/player_monster_2.tscn", \
	PLAYER_CHAR.MONSTER_3: "res://scenes/player_monster_3.tscn" }

enum WEAPONS { NONE, SWORD, GUN }
var player = null
var player_spawnpos = Vector2()
var player_char = PLAYER_CHAR.HUMAN_SWORD

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
var pause_timer







func _ready():
	set_pause_mode( Node.PAUSE_MODE_PROCESS )
	# main scene
	var _root = get_tree().get_root()
	main = _root.get_child( _root.get_child_count() - 1 )
	if main.get_name() != "main":
		main = null
	set_fixed_process( true )


func reset_settings():
	player_char = PLAYER_CHAR.HUMAN
	act_specific = [ \
		{ "scene": 1, "persistent": [] }, \
		{ "scene": 1, "persistent": [] } ]



func _fixed_process( delta ):
	# hit Esc to quit
	if Input.is_key_pressed( KEY_ESCAPE ):
		get_tree().quit()
	
	if get_tree().is_paused():
		if pause_timer > 0:
			pause_timer -= delta
			if pause_timer < 0:
				get_tree().set_pause( false )
		elif pause_timer == -1:
			if Input.is_action_pressed( "btn_fire" ):
				get_tree().set_pause( false )


func pause_game( t ):
	if t > 0:
		pause_timer = t
	else:
		pause_timer = -1
	get_tree().set_pause( true )

func findweak( obj, arr ):
	for idx in range( arr.size() ):
		var aux = arr[idx].get_ref()
		if aux != null and aux == obj:
			return idx
	return -1

func check_fall_area( obj, pos ):
	var space_state = obj.get_world_2d().get_direct_space_state()
	var results = space_state.intersect_point( pos, 32, [], 524288, 16 )
	if not results.empty():
		for r in results:
			if r.collider.is_in_group( "fall_area" ):
				if r.collider.is_in_group( "up_fall" ):
					return 1
				return -1
	return 0