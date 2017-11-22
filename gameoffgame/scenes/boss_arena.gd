extends Area2D

signal entered_boss_arena
var _is_centered = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_boss_arena_body_enter( body ):
	if game.player != null and game.player.get_ref() != null:
		if game.player.get_ref() == body:
			_is_centered = true
			game.camera_target = weakref( self )
			for n in range( 4 ):
				game.camera.get_ref().set_drag_margin( n, 0 )
			emit_signal( "entered_boss_arena" )
			get_node( "block_gate" ).set_layer_mask_bit( 0, true )
			get_node( "block_gate" ).set_layer_mask_bit( 1, true )
			get_node( "block_gate" ).set_layer_mask_bit( 19, true )
			get_node( "block_gate" ).set_collision_mask_bit( 0, true )
			get_node( "block_gate" ).set_collision_mask_bit( 1, true )
			get_node( "block_gate" ).set_collision_mask_bit( 19, true )
func reset():
	get_node( "block_gate" ).set_layer_mask_bit( 0, false )
	get_node( "block_gate" ).set_layer_mask_bit( 1, false )
	get_node( "block_gate" ).set_layer_mask_bit( 19, false )
	get_node( "block_gate" ).set_collision_mask_bit( 0, false )
	get_node( "block_gate" ).set_collision_mask_bit( 1, false )
	get_node( "block_gate" ).set_collision_mask_bit( 19, false )

func _on_setback_timer_timeout():
	for n in range( 4 ):
		game.camera.get_ref().set_drag_margin( n, 0.2 )
