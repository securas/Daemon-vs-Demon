extends Node


#---------------------------
# player info
#---------------------------
enum PLAYER_CHAR { HUMAN, HUMAN_SWORD, HUMAN_GUN, MONSTER_1 }
const CHAR_SCENES = { \
	PLAYER_CHAR.HUMAN: "res://scenes/player_human.tscn", \
	PLAYER_CHAR.HUMAN_SWORD: "res://scenes/player_sword.tscn", \
	PLAYER_CHAR.MONSTER_1: "res://scenes/player_monster_1.tscn" }

enum WEAPONS { NONE, SWORD, GUN }
var player = null
var player_spawnpos = Vector2()
#var player_weapon = WEAPONS.NONE
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


#---------------------------
# act specific
#---------------------------
enum ACTS { HELL, GRAVEYARD }
var act_specific = {
	ACTS.HELL : { "scene": 1, "persistent": [] },
	ACTS.GRAVEYARD : { "scene": 2, "persistent": [] } }




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