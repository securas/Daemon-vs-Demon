extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# set menu active
	get_node( "menulayer/menu" ).set_active( true )
	get_node( "menulayer/menu" ).connect( "selected_item", self, "_on_menu_selected_item" )



func _on_menu_selected_item( item ):
	if item == 0:
		# reset game settings
		
		# start new game
		game.main.act_nxt = "res://scenes/act_1/act_1.tscn"
