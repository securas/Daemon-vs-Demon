extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if game.check_fall_area( self, get_global_pos() ) == 0:
		get_node( "AnimationPlayer" ).play( "fadeout" )
