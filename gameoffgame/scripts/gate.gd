extends StaticBody2D
var _is_open = false
signal gate_open

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



func _on_openarea_body_enter( body ):
	if _is_open: return
	if game.player == null or game.player.get_ref() == null or game.player.get_ref().is_dead(): return
	if game.player.get_ref() != body: return
	if game.has_key:
		# open gate
		#print( "opening gate" )
		_is_open = true
		get_node( "anim" ).play( "open" )
	pass # replace with function body


func _shake_screen( duration = 0.2 ):
	game.camera.get_ref().shake( duration, 30, 4 )