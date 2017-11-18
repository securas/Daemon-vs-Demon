extends Area2D

const VEL = 200
var dir = Vector2()

func _ready():
	set_fixed_process( true )

func _fixed_process( delta ):
	var newpos = get_pos()
	newpos += dir * VEL * delta
	set_pos( newpos )




func _on_monster_bullet_body_enter( body ):
	#explosion
	var explosion = preload( "res://scenes/explosion_1.tscn" ).instance()
	explosion.set_pos( get_pos() )
	get_parent().add_child( explosion )
	queue_free()
	pass # replace with function body


func _on_VisibilityNotifier2D_exit_screen():
	queue_free()
