extends StaticBody2D

signal boss_gate_open
var hit_count = 0
var animation_finished = true

func _ready():
	pass


func play_event(event):
	SoundManager.Play(event)


func _on_hit_area_enter( area ):
	if not animation_finished: return
	if not area extends preload( "res://scripts/explosion_1.gd" ): return
	
	animation_finished = false
	hit_count += 1
	if hit_count > 4:
		return
	get_node( "anim" ).play( "hit_" + str( hit_count ) )
	


func _on_anim_finished():
	animation_finished = true
	if hit_count == 4: 
		game.score += 300
		emit_signal( "boss_gate_open" )

func _shake_screen( duration = 0.2 ):
	game.camera.get_ref().shake( duration, 30, 4 )


var _crossed = false
func _on_cross_game_body_enter( body ):
	if not _crossed and ( game.player != null and game.player.get_ref() != null and body == game.player.get_ref() ):
		_crossed = true
		set_layer_mask_bit( 0, true )
		set_collision_mask_bit( 0, true )
	pass # replace with function body
