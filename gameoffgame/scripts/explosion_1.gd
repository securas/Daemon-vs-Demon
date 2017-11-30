extends Area2D
signal finished_kill
var state = 0
var killing_player = false
var _is_player = false
func _ready():
	set_fixed_process( true )

func play_event(event):
	SoundManager.Play(event)

var frame_count = 0
func _fixed_process(delta):
	if state == 0:
		game.camera.get_ref().shake( 0.5, 30, 4 )
		# find stuff in area
		var gpos = get_global_pos()
		#print( get_name(), " ", frame_count, " overlapping areas: ", get_overlapping_areas() )
		frame_count += 1
		if frame_count < 2: return
		for b in get_overlapping_areas():
			if not _is_player:
				if _get_player() and b.get_parent() == game.player.get_ref():
					# kill player
					killing_player = true
					game.player.get_ref().die( self )
					# instance death scene
					var death = preload( "res://scenes/explosion_kill_player.tscn" ).instance()
					death.get_node( "Sprite" ).set_global_pos( get_global_pos() )
					death.connect( "finished", self, "_on_finished_killing_player_scene" )
					get_parent().add_child( death )
			else:
				print( b.get_name() )
				if b.is_in_group( "damagebox" ) and b.get_parent().is_in_group( "monster" ):
					var monster = b.get_parent()
					print( "explosion hit: ", monster.get_name() )
					# apply force to monster during 0.2 seconds
					monster.set_external_force( \
							10000 * ( monster.get_global_pos() - get_global_pos() ).normalized(), \
							0.2 )
					# hit monster
					monster.get_hit( self )
				pass
		state = 1
		#queue_free()


func _get_player():
	if ( game.player_char == game.PLAYER_CHAR.HUMAN or \
				game.player_char == game.PLAYER_CHAR.HUMAN_SWORD or \
				game.player_char == game.PLAYER_CHAR.HUMAN_GUN ) and \
				game.player != null and game.player.get_ref() != null and \
				( not game.player.get_ref().is_dead() ):
		return game.player.get_ref()
	return null

func _on_finished_killing_player_scene():
	emit_signal( "finished_kill" )
	queue_free()

func _on_AnimationPlayer_finished():
	if not killing_player:
		queue_free()
	pass # replace with function body
