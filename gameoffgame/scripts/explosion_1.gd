extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	game.camera.get_ref().shake( 0.5, 30, 4 )
