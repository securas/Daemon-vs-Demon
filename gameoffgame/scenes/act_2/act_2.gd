extends Node2D

var scene
var scene_starting_state = 3
var state = 0
var state_nxt
var timer = 0
var text_scn = preload( "res://scenes/character_text.tscn" )
onready var player = game.player.get_ref()
var first_transformation = false
var first_activation = false
var startup_scene = false

func _ready():
	scene = game.act_specific[1]["scene"]
	game.camera_target = weakref( get_node( "walls/player" ) )
	
	# player settings
	player.connect( "is_dead", self, "_on_player_dead" )
	player.connect( "on_transformation", self, "_on_transformation" )
	player.set_cutscene()
	player.hide()
	
	# initial respawn point
	game.player_spawnpos = player.get_pos()
	
	# process
	startup_scene = true
	set_fixed_process( true )

func _reset_settings():
	player.connect( "is_dead", self, "_on_player_dead" )
	player.connect( "on_transformation", self, "_on_transformation" )
	player.set_cutscene()
	player.hide()
	game.camera_target = weakref( player )
	first_activation = false
	startup_scene = true
	# reset state
	startup_scene = true
	if scene == 2 and state <= 12:
			state = 0
			scene_starting_state = 3
	else:
		state = 0
		
	# remove player gore
	var children = get_node( "walls" ).get_children()
	for c in children:
		if c.is_in_group( "gore" ): c.queue_free()
	# reset all monsters
	var monsters = get_tree().get_nodes_in_group( "m1" )
	for m in monsters:
		if not m.is_dead(): m.state_nxt = m.STATES.IDLE


func _fixed_process( delta ):
	if startup_scene:
		_startup_scene( delta )
	else:
		if scene == 1:
			_scene_1( delta )
		elif scene == 2:
			_scene_2( delta )
		else:
			set_fixed_process( false )



func _on_first_monsters_body_enter( body ):
	if body == player and not first_activation:
		first_activation = true
		#print("entering area" )
		if scene == 1:
			state = 4
			if game.player!= null and body == game.player.get_ref():
				# launch attack
				var monsters = get_tree().get_nodes_in_group( "m1" )
				for m in monsters:
					m.state_nxt = m.STATES.ATTACK
					m.GRAB_PLAYER_TIME = 0.1
					m.steering_control.max_vel = 3
					pass
		else:
			if game.player!= null and body == game.player.get_ref():
				# launch attack
				var monsters = get_tree().get_nodes_in_group( "m1" )
				for m in monsters:
					if not m.is_dead():
						m.state_nxt = m.STATES.ATTACK

func _on_player_dead():
	if scene == 1:
		#print( "player dead... ending act 2, scene 1" )
		get_node( "endtimer" ).set_wait_time( 2 )
		get_node( "endtimer" ).start()
	else:
		# respawn player at the last respawn point
		var p = preload( "res://scenes/player.tscn" ).instance()
		p.set_pos( game.player_spawnpos )
		get_node( "walls" ).add_child( p )
		player = p
		# reset settings
		_reset_settings()
	

func _on_endtimer_timeout():
	if game.main != null:
		if scene == 1:
			game.main.act_nxt = "res://scenes/act_1/act_1.tscn"
			game.act_specific[1]["scene"] = 2


func _startup_scene( delta ):
	if state == -1:
		# waiting state
		timer -= delta
		if timer <= 0:
			state = state_nxt
	elif state == 0:
		# wait a second
		timer = 1
		state = -1
		state_nxt = 1
	elif state == 1:
		player.show()
		player.arrive()
		timer = 1
		state = -1
		state_nxt = 2
	elif state == 2:
		player.set_cutscene( false )
		state = scene_starting_state
		startup_scene = false


func _scene_1( delta ):
	if state == -1:
		# waiting state
		timer -= delta
		if timer <= 0:
			state = state_nxt
	elif state == 3:
		# do nothing
		pass
	elif state == 4:
		player.set_cutscene()
		_player_text( "Oh...", 1, 3, 5 )
	elif state == 5:
		_player_text( "Hi guys!", 2, 3, 6 )
	elif state == 6:
		_demon_text( "HUMAN!...", 2, 2, 7 )
	elif state == 7:
		_demon_text( "MUST DIE!", 2, 2, 8 )
	elif state == 8:
		_player_text( "Wait!!!", 2, 2, 9 )
	elif state == 9:
		_player_text( "We're on the same team...", 2, 2, 10 )
	elif state == 10:
		_player_text( "... Right?", 2, 3, 11 )
	elif state == 11:
		_demon_text( "MUST DIE!", 2, 3, 12 )
		var monsters = get_tree().get_nodes_in_group( "m1" )
		for m in monsters:
			m.state_nxt = m.STATES.ATTACK
			m.GRAB_PLAYER_TIME = 0.1
			m.steering_control.max_vel = 20
	elif state == 12:
		_demon_text( "MUST DIE!", 2, 3, 13 )
		var monsters = get_tree().get_nodes_in_group( "m1" )
		for m in monsters:
			m.state_nxt = m.STATES.ATTACK
			m.GRAB_PLAYER_TIME = 0.1
			m.steering_control.max_vel = 80
	
func _scene_2( delta ):
	if state == -1:
		# waiting state
		timer -= delta
		if timer <= 0:
			state = state_nxt
	elif state == 3:
		# check if any monsters are alive
		var monsters_alive = false
		var monsters = get_tree().get_nodes_in_group( "m1" )
		for m in monsters:
			if not m.is_dead():
				monsters_alive = true
				break
		if not monsters_alive:
			state = 4
	elif state == 4:
		timer = 1
		state = -1
		state_nxt = 5
	elif state == 5:
		if not first_transformation:
			_player_text( "I wonder...", 2, 2, 6 )
		else:
			state = 8
	elif state == 6:
		if not first_transformation:
			_player_text( "... Maybe I can drink this blood...", 2, 2, 7 )
		else:
			state = 8
	elif state == 7:
		if not first_transformation:
			_player_text( "... Instead of human blood", 2, 2, 8 )
		else:
			state = 8
	elif state == 8:
		if first_transformation:
			timer = 1
			state = -1
			state_nxt = 9
	elif state == 9:
		_player_text( "Hum...", 2, 2, 10 )
	elif state == 10:
		_player_text( "... was not expecting this.", 2, 2, 11 )
	elif state == 11:
		# next scene
		game.act_specific[1]["scene"] = 3
		state_nxt = 12
	


func _player_text( msg, ttext, ttimer, nxt, voffset = -30 ):
	var t = text_scn.instance()
	t.set_text( msg )
	t.connect( "finished", self, "_on_text_finished" )
	t.connect( "interrupted", self, "_on_text_interrupted" )
	player.add_child( t )
	t.set_offsetpos( Vector2( 0, voffset ) )
	t.set_timer( ttext )
	
	t = null
	timer = ttimer
	state = -1
	state_nxt = nxt

func _demon_text( msg, ttext, ttimer, nxt, voffset = -30 ):
	var t = text_scn.instance()
	t.set_text( msg )
	t.add_color_override("font_color", Color(0.7,0,0))
	t.connect( "finished", self, "_on_text_finished" )
	t.connect( "interrupted", self, "_on_text_interrupted" )
	get_node( "walls/talking_monster" ).add_child( t )
	t.set_offsetpos( Vector2( 0, voffset ) )
	t.set_timer( ttext )
	timer = ttimer
	state = -1
	state_nxt = nxt
	t = null


func _on_transformation():
	if first_transformation: return
	if game.player_char != game.PLAYER_CHAR.HUMAN or \
			game.player_char != game.PLAYER_CHAR.HUMAN_SWORD or \
			game.player_char != game.PLAYER_CHAR.HUMAN_GUN:
		first_transformation = true