extends Node2D
# Notes: old bg color: 32, 49, 50

var scene
var text_scn = preload( "res://scenes/character_text.tscn" )


class EvtState:
	var fnc
	var state = 0
	var state_nxt
	var active = false
	var timer = 0
	var first_time = true
	func _init( obj, fnc ):
		self.fnc = funcref( obj, fnc )

# enumerate stuff that is persistent when restarting level
enum PERSISTENT { \
		KILLED_MONSTERS_1, \
		FIRST_TRANSFORMATION }
# enumerate events
enum EVENTS { \
		STARTUP, \
		MEET_MONSTERS, \
		KILLED_MONSTERS_1, \
		FIRST_TRANSFORMATION, \
		MEET_BOSS, \
		BOSS_DYING, \
		BOSS_DEAD }
onready var events = \
	{ \
		EVENTS.STARTUP : EvtState.new( self, "_evt_startup" ), \
		EVENTS.MEET_MONSTERS : EvtState.new( self, "_evt_meet_monsters" ), \
		EVENTS.KILLED_MONSTERS_1 : EvtState.new( self, "_evt_kill_monsters_1" ), \
		EVENTS.FIRST_TRANSFORMATION : EvtState.new( self, "_evt_first_transform" ), \
		EVENTS.MEET_BOSS: EvtState.new( self, "_evt_meet_boss" ), \
		EVENTS.BOSS_DYING : EvtState.new( self, "_evt_boss_dying" ), \
		EVENTS.BOSS_DEAD : EvtState.new( self, "_evt_boss_dead" )
	}
		
	



func _ready():
	scene = game.act_specific[game.ACTS.GRAVEYARD]["scene"]
	game.camera_target = weakref( get_node( "walls/player" ) )
	
	# player settings
	_reset_settings()
	
	# initial respawn point
	if game.player != null and game.player.get_ref() != null:
		game.player_spawnpos = game.player.get_ref().get_global_pos()
	
	# initial monster positions
#	var monsters = get_tree().get_nodes_in_group( "monster" )
#	for m in monsters:
#		initial_monsters.append( weakref( m ) )
#		initial_monster_positions.append( m.get_pos() )
	
	# connect to respawn areas
	var areas = get_node( "areas/respawn_areas" ).get_children()
	for a in areas:
		a.connect( "body_enter", self, "_on_respawn_body_enter", [ a ] )
	
	# connect to boss arena
	get_node( "areas/boss_arena" ).connect( "entered_boss_arena", self, "_on_entered_boss_arena" )
	# connect to boss
	get_node( "walls/boss" ).connect( "boss_dying", self, "_on_boss_dying" )
	get_node( "walls/boss" ).connect( "boss_dead", self, "_on_boss_dead" )
	
	# process
	set_fixed_process( true )


func _reset_settings():
	var player = null
	if game.player != null and game.player.get_ref() != null:
		player = game.player.get_ref()
	else:
		print( "reset settings: could not find player!" )
		return
	events[EVENTS.STARTUP].active = true
	player.connect( "is_dead", self, "_on_player_dead" )
	player.connect( "on_transformation", self, "_on_transformation" )
	player.set_cutscene()
	player.hide()
	game.camera_target = weakref( player )
	game.camera.get_ref().align()
	game.camera.get_ref().reset_smoothing()
	player = null
	# remove player gore
	var children = get_node( "walls" ).get_children()
	for c in children:
		if c.is_in_group( "gore" ): c.queue_free()
	# boss
	game.boss_fight = false
	get_node( "walls/boss" ).hits = 0
	get_node( "walls/boss" ).reset_position()
	get_node( "areas/boss_arena" ).reset()


func _fixed_process( delta ):
	# cycle events
	for e in events:
		if events[e].active:
			events[e].fnc.call_func( delta, events[e] )






func _evt_startup( delta, evt ):
	if evt.state == -1:
		# waiting state
		evt.timer -= delta
		if evt.timer <= 0:
			evt.state = evt.state_nxt
	elif evt.state == 0:
		print( "event startup" )
		# wait a second
		evt.timer = 1
		evt.state = -1
		evt.state_nxt = 1
	elif evt.state == 1:
		if game.player != null and game.player.get_ref() != null:
			game.player.get_ref().show()
			game.player.get_ref().arrive()
		evt.timer = 1
		evt.state = -1
		evt.state_nxt = 2
	elif evt.state == 2:
		if game.player != null and game.player.get_ref() != null:
			game.player.get_ref().set_cutscene( false )
		# end this event
		evt.active = false
		evt.state = 0





func _evt_meet_monsters( delta, evt ):
	if evt.state == -1:
		# waiting state
		evt.timer -= delta
		if evt.timer <= 0:
			evt.state = evt.state_nxt
	elif evt.state == 0:
		# launch attack
		var monsters = get_tree().get_nodes_in_group( "m1" )
		for m in monsters:
			m.state_nxt = m.STATES.ATTACK
			m.GRAB_PLAYER_TIME = 0.1
			m.steering_control.max_vel = 3
		evt.state = 1
	elif evt.state == 1:
		print( "trying to set cutscene" )
		if game.player != null and game.player.get_ref() != null:
			print( "setting cutscene" )
			game.player.get_ref().set_cutscene()
		_player_text( "Oh...", 1, 3, 2, evt )
	elif evt.state == 2:
		_player_text( "Hi guys!", 2, 3, 3, evt )
	elif evt.state == 3:
		_demon_text( "HUMAN!...", 2, 2, 4, evt )
	elif evt.state == 4:
		_demon_text( "MUST DIE!", 2, 2, 5, evt )
	elif evt.state == 5:
		_player_text( "Wait!!!", 2, 2, 6, evt )
	elif evt.state == 6:
		_player_text( "We're on the same team...", 2, 2, 7, evt )
	elif evt.state == 7:
		_player_text( "... Right?", 2, 3, 8, evt )
	elif evt.state == 8:
		_demon_text( "MUST DIE!", 2, 3, 9, evt )
		var monsters = get_tree().get_nodes_in_group( "m1" )
		for m in monsters:
			m.state_nxt = m.STATES.ATTACK
			m.GRAB_PLAYER_TIME = 0.1
			m.steering_control.max_vel = 20
	elif evt.state == 9:
		_demon_text( "MUST DIE!", 2, 3, 10, evt )
		var monsters = get_tree().get_nodes_in_group( "m1" )
		for m in monsters:
			m.state_nxt = m.STATES.ATTACK
			m.GRAB_PLAYER_TIME = 0.1
			m.steering_control.max_vel = 80
	elif evt.state == 10:
		evt.active = false





func _evt_kill_monsters_1( delta, evt ):
	# this event may be interrupted at any point
	# if the first transformation has already occured
	if game.act_specific[game.ACTS.GRAVEYARD]["persistent"].find( PERSISTENT.FIRST_TRANSFORMATION ) != -1:
		evt.active = false
		game.act_specific[game.ACTS.GRAVEYARD]["persistent"].append( PERSISTENT.KILLED_MONSTERS_1 )
	else:
		# normal
		if evt.state == -1:
			# waiting state
			evt.timer -= delta
			if evt.timer <= 0:
				evt.state = evt.state_nxt
		elif evt.state == 0:
			# monitor monsters
			var monsters = get_tree().get_nodes_in_group( "m1" )
			var monsters_all_dead = true
			for m in monsters:
				if not m.is_dead():
					monsters_all_dead = false
					break
			if monsters_all_dead:
				evt.state = 1
		elif evt.state == 1:
			evt.timer = 1
			evt.state = -1
			evt.state_nxt = 2
		elif evt.state == 2:
			_player_text( "I wonder...", 2, 2, 3, evt )
		elif evt.state == 3:
			_player_text( "... Maybe I can have this blood.", 2, 2, 4, evt )
		elif evt.state == 4:
			# end this event
			evt.active = false
			# set persistent notice
			game.act_specific[game.ACTS.GRAVEYARD]["persistent"].append( PERSISTENT.KILLED_MONSTERS_1 )


func _evt_first_transform( delta, evt ):
	if evt.state == -1:
		# waiting state
		evt.timer -= delta
		if evt.timer <= 0:
			evt.state = evt.state_nxt
	elif evt.state == 0:
		# set persistent notice
		game.act_specific[game.ACTS.GRAVEYARD]["persistent"].append( PERSISTENT.FIRST_TRANSFORMATION )
		evt.timer = 1
		evt.state = -1
		evt.state_nxt = 1
	elif evt.state == 1:
		_player_text( "Hum...", 2, 2, 2, evt )
	elif evt.state == 2:
		_player_text( "... was not expecting this.", 2, 2, 3, evt )
	elif evt.state == 3:
		# finish this event
		evt.active = false



func _evt_meet_boss( delta, evt ):
	if evt.state == -1:
		# waiting state
		evt.timer -= delta
		if evt.timer <= 0:
			evt.state = evt.state_nxt
	elif evt.state == 0:
		# freeze player
		game.player.get_ref().set_cutscene()
		# wait a second
		evt.timer = 1
		evt.state = -1
		evt.state_nxt = 1
	elif evt.state == 1:
		_boss_text( "You have arrived... Finally!", 2, 2, 2, evt )
	elif evt.state == 2:
		_player_text( "You're a big one...", 2, 2, 3, evt )
	elif evt.state == 3:
		_boss_text( "I am Satan... Lord of the Underworld!", 2, 2, 4, evt )
	elif evt.state == 4:
		_player_text( "... will you squeal like the others?.", 2, 2, 5, evt )
	elif evt.state == 5:
		_boss_text( "Ha! Ha! Ha! You are funny!", 2, 2, 6, evt )
	elif evt.state == 6:
		_boss_text( "I used to be like you...", 2, 2, 7, evt )
	elif evt.state == 7:
		_boss_text( "... before I defeated my predecessor.", 2, 2, 8, evt )
	elif evt.state == 8:
		_player_text( "Shut up and fight!", 2, 2, 9, evt )
	elif evt.state == 9:
		game.player.get_ref().set_cutscene( false )
		game.boss_fight = true
		evt.active = false




func _evt_boss_dying( delta, evt ):
	if evt.state == -1:
		# waiting state
		evt.timer -= delta
		if evt.timer <= 0:
			evt.state = evt.state_nxt
	elif evt.state == 0:
		# freeze player
		game.player.get_ref().set_cutscene()
		# wait a second
		evt.timer = 1
		evt.state = -1
		evt.state_nxt = 1
	elif evt.state == 1:
		_boss_text( "I knew this day would come...", 2, 2, 2, evt )
	elif evt.state == 2:
		_player_text( "Getting your butt kicked?", 2, 2, 3, evt )
	elif evt.state == 3:
		_boss_text( "... to finally be free.", 2, 2, 4, evt )
	elif evt.state == 4:
		_player_text( "???", 2, 2, 5, evt )
		get_node( "walls/boss" ).state_nxt = get_node( "walls/boss" ).STATES.DEAD
		get_node( "walls/rain" ).stop()
	elif evt.state == 5:
		# finish this event
		evt.active = false


func _evt_boss_dead( delta, evt ):
	if evt.state == -1:
		# waiting state
		evt.timer -= delta
		if evt.timer <= 0:
			evt.state = evt.state_nxt
	elif evt.state == 0:
		# freeze player
		game.player.get_ref().set_cutscene()
		# wait a second
		evt.timer = 2
		evt.state = -1
		evt.state_nxt = 1
	elif evt.state == 1:
		_player_text( "I wonder...", 2, 2, 2, evt )
	elif evt.state == 2:
		_player_text( "... should I take his form?", 4, 4, 3, evt )
	elif evt.state == 3:
		if game.main != null:
			game.main.act_nxt = "res://scenes/act_3/act_3.tscn"
		evt.active = false







func _on_first_monsters_body_enter( body ):
	if game.player != null and body == game.player.get_ref():
		if scene == 1:
			events[EVENTS.MEET_MONSTERS].active = true
		else:
			# start event to monitor monsters
			if game.act_specific[game.ACTS.GRAVEYARD]["persistent"].find( PERSISTENT.KILLED_MONSTERS_1 ) == -1:
				events[EVENTS.KILLED_MONSTERS_1].active = true
			var monsters = get_tree().get_nodes_in_group( "m1" )
			for m in monsters:
				if not m.is_dead(): m.state_nxt = m.STATES.ATTACK
			#game.camera_target = weakref( get_node( "areas/first_monsters" ) )
		#else:
		#	var monsters = get_tree().get_nodes_in_group( "m1" )
		#	for m in monsters:
		#		m.state_nxt = m.STATES.ATTACK
func _on_first_monsters_body_exit( body ):
	#game.camera_target = game.player
	pass # replace with function body


func _on_transformation():
	# check if the first transformation has occured
	if game.act_specific[game.ACTS.GRAVEYARD]["persistent"].find( PERSISTENT.FIRST_TRANSFORMATION ) != -1:
		return
	# check if the player transformed to something other than human
	if game.player_char != game.PLAYER_CHAR.HUMAN or \
			game.player_char != game.PLAYER_CHAR.HUMAN_SWORD or \
			game.player_char != game.PLAYER_CHAR.HUMAN_GUN:
		# start the first transformation event
		events[EVENTS.FIRST_TRANSFORMATION].active = true
		pass




func _on_player_dead():
	if scene == 1:
		#print( "player dead... ending act 2, scene 1" )
		get_node( "endtimer" ).set_wait_time( 2 )
		get_node( "endtimer" ).start()
	else:
		# respawn player at the last respawn point
		var p = preload( "res://scenes/player.tscn" ).instance()
		p.set_global_pos( game.player_spawnpos )
		get_node( "walls" ).add_child( p )
		# reset settings
		_reset_settings()
	

func _on_endtimer_timeout():
	if game.main != null:
		if scene == 1:
			game.main.act_nxt = "res://scenes/act_1/act_1.tscn"
			game.act_specific[1]["scene"] = 2




func _on_entered_boss_arena():
	events[EVENTS.MEET_BOSS].active = true

func _on_boss_dying():
	events[EVENTS.BOSS_DYING].active = true


func _on_boss_dead():
	events[EVENTS.BOSS_DEAD].active = true




func _player_text( msg, ttext, ttimer, nxt, evt ):
	_create_text( game.player, \
			Color(1,1,1), \
			msg, ttext, ttimer, nxt, evt )

func _demon_text( msg, ttext, ttimer, nxt, evt ):
	_create_text( weakref( get_node( "walls/talking_monster" ) ), \
			Color(0.7,0.8,0.1), \
			msg, ttext, ttimer, nxt, evt )

func _boss_text( msg, ttext, ttimer, nxt, evt ):
	_create_text( weakref( get_node( "walls/boss" ) ), \
			Color( 1, 1, 0 ), \
			msg, ttext, ttimer, nxt, evt, Vector2( 0, -35 ) )



func _create_text( target, color, msg, ttext, ttimer, nxt, evt, offsetpos = Vector2( 0, -30 ) ):
	var t = text_scn.instance()
	t.set_text( msg )
	t.connect( "interrupted", self, "_on_text_interrupted", [evt] )
	t.add_color_override("font_color", color )
	t.target_node = target
	t.set_offsetpos( offsetpos )
	get_node( "infolayer" ).add_child( t )
	t.set_timer( ttext )
	evt.timer = ttimer
	evt.state = -1
	evt.state_nxt = nxt
	t = null

func _on_text_interrupted(evt):
	evt.timer = 0


#func _on_monsters_2_body_enter( body ):
#	if game.player != null and body == game.player.get_ref():
#		var monsters = get_tree().get_nodes_in_group( "m2" )
#		for m in monsters:
#			if not m.is_dead(): m.state_nxt = m.STATES.ATTACK


#-----------------------------------------------------
# function called to update respawn area
#-----------------------------------------------------
func _on_respawn_body_enter( body, area ):
	if game.player != null and body == game.player.get_ref():
		game.player_spawnpos = area.get_global_pos()





#func _on_monsters_3_body_enter( body ):
#	if game.player != null and body == game.player.get_ref():
#		var monsters = get_tree().get_nodes_in_group( "m3" )
#		for m in monsters:
#			if not m.is_dead(): m.state_nxt = m.STATES.ATTACK


func _on_monsters_body_enter( body, group ):
	if game.player != null and body == game.player.get_ref():
		var monsters = get_tree().get_nodes_in_group( group )
		for m in monsters:
			if not m.is_dead(): m.state_nxt = m.STATES.ATTACK
