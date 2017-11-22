extends Label

signal finished
signal interrupted
var _is_finished = false
var offset_pos = Vector2()
var target_node = null

func _ready():
	set_process_input( true )
	if target_node != null:
		set_fixed_process( true )

func _fixed_process(delta):
	if target_node.get_ref() != null:
		set_pos( target_node.get_ref().get_global_transform_with_canvas().o - get_size() / 2 + offset_pos )

func set_timer( a ):
	get_node( "Timer" ).set_wait_time( a )
	get_node( "Timer" ).start()

func set_offsetpos( p ):
	offset_pos = p
	set_pos( get_pos()+p )

func _input(event):
	if event.is_action_pressed( "btn_fire" ) and _is_finished == false:
		get_node( "Timer" ).stop()
		_is_finished = true
		emit_signal( "interrupted" )
		queue_free()



func _on_Timer_timeout():
	if _is_finished == false:
		_is_finished = true
		emit_signal( "finished" )
		queue_free()



#func _draw():
#	var pos = Vector2( 168, 96 )
#	draw_circle( pos - get_global_pos(), 10, Color( 1, 0, 0 ) )