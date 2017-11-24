extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	#print( "in the air: ", game.check_fall_area( self, get_global_pos() ) )
	if game.check_fall_area( self, get_global_pos() ) != 0:
		queue_free()
		#get_node( "AnimationPlayer" ).play( "fadeout" )
