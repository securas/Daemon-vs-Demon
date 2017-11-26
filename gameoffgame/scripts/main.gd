extends Node2D



#-------------------------------
# Load music
#-------------------------------
var music = { \
	"res://scenes/intro/intro.tscn" : { \
		"music": { \
			"file" : "res://sound/incompetech.com_Oppressive Gloom.ogg", \
			"res" : null, \
			"start_delay" : 2, \
			"restart" : false, \
			"smooth" : [ 0, 0 ] },
		"bg": { \
			"file" : "", \
			"res" : null, \
			"start_delay" : 0, \
			"restart" : false, \
			"smooth" : [ 0, 0 ] } }, \
	"res://scenes/act_1/act_1.tscn" : { \
		"music": { \
			"file" : "res://sound/incompetech.com_Oppressive Gloom.ogg", \
			"res" : null, \
			"start_delay" : 2, \
			"restart" : false, \
			"smooth" : [ 0, 0 ] },
		"bg": { \
			"file" : "", \
			"res" : null, \
			"start_delay" : 0, \
			"restart" : false, \
			"smooth" : [ 0, 0 ] } }, \
	"res://scenes/act_2/act_2.tscn" : { \
		"music": { \
			"file" : "res://sound/incompetech.com_Shadowlands 4 - Breath.ogg", \
			"res" : null, \
			"start_delay" : 0, \
			"restart" : false, \
			"smooth" : [ 0, 0 ] },
		"bg": { \
			"file" : "res://sound/freesound.org__arctura__ambient-rain-light-loop.ogg", \
			"res" : null, \
			"start_delay" : 0, \
			"restart" : false, \
			"smooth" : [ 0, 0 ] } } }



var input_states = preload( "res://scripts/input_states.gd" )
var btn_quit = input_states.new( "btn_quit" )

#"res://scenes/intro/intro.tscn"
var act_cur = ""
var act_nxt = "res://scenes/intro/start.tscn" setget _load_act
var load_state = 0
onready var loadtimer = get_node( "loadtimer" )
var state = -10
var state_nxt = -10
var timer = 0
func _ready():
#	# load all the music files
#	for sc in music:
#		for s in music[sc]:
#			if not music[sc]["music"]["file"].empty():
#				print( "Loading: ", music[sc]["music"]["file"] )
#				music[sc]["music"]["res"] = load( music[sc]["music"]["file"] )
#			if not music[sc]["bg"]["file"].empty():
#				print( "Loading: ", music[sc]["bg"]["file"] )
#				music[sc]["bg"]["res"] = load( music[sc]["bg"]["file"] )

	# connect pause menu
	get_node( "hud_layer/pause_game/menu" ).connect( "selected_item", self, "_on_pause_menu_selected_item" )
	set_fixed_process( true )
	_load_act( act_nxt )
	pass

var score_cur = 0
var score_nxt = 0
var _ingame = false
var _is_paused = false
var _allowinput = false
func _fixed_process( delta ):
	
	# manage score
	if score_cur < score_nxt:
		if get_node( "hud_layer/hud/score/score_animator" ).get_current_animation() != "fadein":
			get_node( "hud_layer/hud/score/score_animator" ).play( "fadein" )
		score_cur += 5
		if score_cur >= score_nxt:
			score_cur = score_nxt
			#print( "fading out score" )
			get_node( "hud_layer/hud/score/score_animator" ).play( "fadeout" )
		get_node( "hud_layer/hud/score/score" ).set_text( "%05d" % score_cur )
	
	# player input
	if _allowinput:
		if _ingame:
			# in this mode, pressing the quit button pauses the game
			if btn_quit.check() == 1:
				if not _is_paused:
					_is_paused = true
					# show pause screen
					get_node( "hud_layer/pause_game/pause_animator" ).play( "fadein" )
					# activate pause menu
					get_node( "hud_layer/pause_game/menu" ).set_active( true )
					pause_game()
				else:
					# pressing quit when paused returns to the game
					_is_paused = false
					get_node( "hud_layer/pause_game/pause_animator" ).play( "fadeout" )
					pause_game( false )
#		else:
#			# in this mode, pressing the quit button quits the game
#			if btn_quit.check() == 1:
#				_load_act( "res://scenes/intro/intro.tscn" )


func _on_pause_menu_selected_item( item ):
	print( "pause menu option: ", item )
	_is_paused = false
	get_node( "hud_layer/pause_game/pause_animator" ).play( "fadeout" )
	get_node( "hud_layer/pause_game/menu" ).set_active( false )
	pause_game( false )
	if item == 1:
		#quit
		get_node( "hud_layer/pause_game/menu" ).cur_pos = 0
		_load_act( "res://scenes/intro/intro.tscn" )









func _load_act( newact ):
	act_nxt = newact
	if act_cur == act_nxt: return
	load_state = 0
	_load_act_fsm( act_cur )



func _load_act_fsm( act_cur ):
	if load_state == 0:
		_allowinput = false
		_ingame = false
		# fade out
		fadein( false )
		load_state = 1
		loadtimer.set_wait_time( 0.3 )
		loadtimer.start()
	elif load_state == 1:
		# hide hud
		get_node( "hud_layer/hud" ).hide()
		# clear current act
		var children = get_node( "act" ).get_children()
		for c in children:
			c.queue_free()
		load_state = 2
		loadtimer.set_wait_time( 0.3 )
		loadtimer.start()
	elif load_state == 2:
		# load new act
		var act_scn = load( act_nxt )
		var act = act_scn.instance()
		get_node( "act" ).add_child( act )
		# act specific settings
		if act_nxt == "res://scenes/act_2/act_2.tscn":
			#print( "showing hud" )
			_ingame = true
			get_node( "hud_layer/hud" ).show()
		elif act_nxt == "res://scenes/act_1/act_1.tscn":
			_ingame = true
		load_state = 3
		loadtimer.set_wait_time( 0.1 )
		loadtimer.start()
	elif load_state == 3:
		pause_game()
		# fade in
		fadein()
		# play stuff
#		play_act( act_nxt )
		load_state = 4
		loadtimer.set_wait_time( 0.25 )
		loadtimer.start()
	elif load_state == 4:
		# unpause game
		pause_game( false )
		
		_allowinput = true
		load_state = 0

func _on_loadtimer_timeout():
	_load_act_fsm( act_cur )


func pause_game( v = true ):
	if v:
		get_tree().set_pause( true )
	else:
		get_tree().set_pause( false )

func fadein( v = true ):
	if v:
		get_node( "hud_layer/fading/fading_animator" ).play( "fadein" )
	else:
		get_node( "hud_layer/fading/fading_animator" ).play( "fadeout" )



func set_key( v ):
	if v:
		get_node( "hud_layer/hud/key/key_animator" ).play( "fadein" )
	else:
		get_node( "hud_layer/hud/key/key_animator" ).play( "fadeout" )


func progress_update():
	get_node( "hud_layer/hud/progress_indicator/AnimationPlayer" ).play( "show" )
func _hide_progress_update():
	get_node( "hud_layer/hud/progress_indicator/AnimationPlayer" ).play( "hide" )





func play_sfx( name ):
	get_node( "SamplePlayer" ).play( name )





func play_act( act ):
	if not music.has( act ): return
	if music[act]["music"]["res"] != null:
		if get_node( "music" ).get_stream() != music[act]["music"]["res"]:
			get_node( "music" ).set_stream( music[act]["music"]["res"] )
			if music[act]["music"]["start_delay"] > 0:
				get_node( "music_timer" ).set_wait_time( music[act]["music"]["start_delay"] )
				get_node( "music_timer" ).start()
			else:
				get_node( "music" ).play()
				#_start_music( music[act]["smooth"][0] )
		elif music[act]["music"]["restart"]:
			#_stop_music( music[act]["smooth"][1] )
			get_node( "music" ).stop()
			if music[act]["music"]["start_delay"] > 0:
				get_node( "music_timer" ).set_wait_time( music[act]["music"]["start_delay"] )
				get_node( "music_timer" ).start()
			else:
				get_node( "music" ).play()
	else:
		get_node( "music" ).stop()
		
	if music[act]["bg"]["res"] != null:
		if get_node( "background" ).get_stream() != music[act]["bg"]["res"]:
			get_node( "background" ).set_stream( music[act]["bg"]["res"] )
			if music[act]["bg"]["start_delay"] > 0:
				get_node( "background_timer" ).set_wait_time( music[act]["bg"]["start_delay"] )
				get_node( "background_timer" ).start()
			else:
				get_node( "background" ).play()
		elif music[act]["bg"]["restart"]:
			get_node( "background" ).stop()
			if music[act]["bg"]["start_delay"] > 0:
				get_node( "background_timer" ).set_wait_time( music[act]["bg"]["start_delay"] )
				get_node( "background_timer" ).start()
			else:
				get_node( "background" ).play()
		else:
			get_node( "music" ).stop()


func _on_music_timer_timeout():
	get_node( "music" ).play()


func _on_background_timer_timeout():
	return
	get_node( "background" ).play()
