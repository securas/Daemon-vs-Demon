extends Node2D

var input_states = preload( "res://scripts/input_states.gd" )
var btn_fire = input_states.new( "btn_fire" )

func _ready():
	set_process_input( true )


func _input(event):
	if event.is_action_pressed( "btn_fire" ) or event.is_action_pressed( "btn_quit" ):
		game.main.act_nxt = "res://scenes/intro/intro.tscn"