extends Area2D

var player_entered = false
var monster_array = []
func _ready():
	pass


var monster_count = 10
var timer = 0
const SPAWN_INTERVAL = 0.25
func _fixed_process(delta):
	timer -= delta
	if timer <= 0:
		timer = SPAWN_INTERVAL
		if monster_count >= 0:
			monster_count -= 1
			var monster = preload( "res://scenes/monster_2.tscn" ).instance()
			monster.set_pos( get_node( "spawn_pos" ).get_global_pos() )
			get_parent().get_parent().get_parent().get_node( "walls" ).add_child( monster )
			
			monster.state_nxt = monster.STATES.ATTACK
			monster_array.append( weakref( monster ) )
		else:
			set_fixed_process( false )

func _on_patrol_and_spawn_body_enter( body ):
	if player_entered: return
	if game.player != null and body == game.player.get_ref() and game.player_char == game.PLAYER_CHAR.HUMAN_SWORD:
		#print( "starting spawn" )
		player_entered = true
		set_fixed_process( true )
		body.connect( "is_dead", self, "_on_player_dead" )

func _on_player_dead():
	return
	for m in monster_array:
		if m.get_ref() != null:
			m.get_ref().queue_free()
	player_entered = false
