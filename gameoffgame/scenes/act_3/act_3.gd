extends Node2D



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _input(event):
	if event.is_action_pressed( "btn_fire" ) or event.is_action_pressed( "btn_quit" ):
		game.reset_settings()
		game.continue_game = false
		game.main.act_nxt = "res://scenes/intro/intro.tscn"
		set_process_input( false )


func _on_input_timer_timeout():
	set_process_input( true )
