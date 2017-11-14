extends Label

signal finished
signal interrupted
var _is_finished = false

func _ready():
	set_process_input( true )

func set_timer( a ):
	get_node( "Timer" ).set_wait_time( a )
	get_node( "Timer" ).start()

func set_offsetpos( p ):
	#print( get_pos(), "  ", p )
	set_pos( get_pos()+p )
	#print( get_pos() )

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
