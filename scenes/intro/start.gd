extends Node2D

var input_states = preload( "res://scripts/input_states.gd" )
var btn_fire = input_states.new( "btn_fire" )

func _ready():
	set_process_input( true )


func _input(event):
	#print( "EVENT: ", event.type, " ", InputEvent.MOUSE_BUTTON, " ",  InputEvent.MOUSE_BUTTON )
	if event.type == InputEvent.MOUSE_MOTION or event.type == InputEvent.MOUSE_BUTTON: return
	game.main.act_nxt = "res://scenes/intro/intro.tscn"
	set_process_input( false )
#	if event.is_action_pressed( "btn_fire" ) or event.is_action_pressed( "btn_quit" ):
#		get_node( "Timer" ).stop()
#		game.main.act_nxt = "res://scenes/intro/intro.tscn"

func _on_Timer_timeout():
	game.main.act_nxt = "res://scenes/intro/intro.tscn"
