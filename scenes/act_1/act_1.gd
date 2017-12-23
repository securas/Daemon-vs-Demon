extends Node2D

var text_scn = preload( "res://scenes/character_text.tscn" )

var scene = 1
# 1 is the initial scene of the game

onready var player = get_node( "YSort/player" )

func _ready():
	scene = game.act_specific[0]["scene"]
	# set player properties
	player.set_cutscene()
	player.hide()
	game.continue_game = true
	game.cur_act = game.ACTS.HELL
	SoundManager.StopStream()
	SoundManager.Play("mus_intro")
	SoundManager.Play("amb_hell_noise")
	
	# start process
	set_fixed_process( true )


var state = 0
var state_nxt = 0
var timer = 0
var set_number = false
func _fixed_process( delta ):
	if Input.is_action_pressed( "btn_down" ):
		intro_end()
	if scene == 1:
		_scene_1( delta )
	elif scene == 2:
		_scene_2( delta )
	if set_number == false and scene > 1:
		get_node( "YSort/hell_sign/number" ).set_region_rect( Rect2( Vector2( 53, 5 ), Vector2( 3, 3 ) ) )
		set_number = true
		


func intro_end():
	game.act_specific[0]["scene"] = 3
	game.act_specific[1]["scene"] = 2
	game.player_char = game.PLAYER_CHAR.HUMAN_SWORD
	if game.main != null:
		game.main.act_nxt = "res://scenes/act_2/act_2.tscn"


func _scene_1( delta ):
	if state == -1:
		# waiting state
		timer -= delta
		if timer <= 0:
			state = state_nxt
	elif state == 0:
		#print( state )
		# demon plays games
		get_node( "YSort/blood_pool/demon" ).set_scale( Vector2( -1, 1 ) )
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "game" )
		# population 1
		get_node( "YSort/hell_sign/number" ).set_region_rect( Rect2( Vector2( 53, 1 ), Vector2( 3, 3 ) ) )
		# start a timer before begining
		timer = 2
		state = -1
		state_nxt = 1
	elif state == 1:
		# player arrives
		player.show()
		#player._set_fx_animation( player.ANIMATIONS_FX.ARRIVE )
		player.arrive()
		timer = 2
		state = -1
		state_nxt = 2
	elif state == 2:
		# looks to the left
		player.look_behind()
		timer = 2
		state = -1
		state_nxt = 3
	elif state == 3:
		# looks to the right
		player.look_behind( false )
		timer = 2
		state = -1
		state_nxt = 4
	elif state == 4:
		# looks to the left again
		player.look_behind()
		timer = 1
		state = -1
		state_nxt = 5
	elif state == 5:
		# looks to the right again
		player.look_behind( false )
		timer = 1
		state = -1
		state_nxt = 6
	elif state == 6:
		# player says hi
		_player_text( "Huh... Hello?", 3, 2, 7 )
	elif state == 7:
		#print( state )
		# demon looks at player
		get_node( "YSort/blood_pool/demon" ).set_scale( Vector2( 1, 1 ) )
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "face" )
		timer = 1
		state = -1
		state_nxt = 8
	elif state == 8:
		_demon_text( "What are you doing here? We're closed!", 3, 3, 9 )
	elif state == 9:
		_player_text( "Where am I?", 2, 2, 10 )
	elif state == 10:
		_demon_text( "In Hell! How did you get here? Everyone left!", 3, 3, 12 )
	elif state == 11:
		_demon_text( "How did you get here?", 3, 3, 12 )
	elif state == 12:
		_player_text( "I huh... died.", 2, 2, 13 )
	elif state == 13:
		# demon looks at pad
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "game" )
		timer = 1
		state = -1
		state_nxt = 19#14
	elif state == 14:
		_demon_text( "That makes no sense...", 2, 2, 15 )
	elif state == 15:
		#print( state )
		_demon_text( "... We're closed.", 2, 3, 16 )
	elif state == 16:
		#print( state )
		#get_node( "YSort/blood_pool/demon/anim_body" ).play( "face" )
		_demon_text( "But here it says...", 2, 2, 17 )
	elif state == 17:
		#print( state )
		_demon_text( "... you're supposed to come.", 3, 3, 18 )
	elif state == 18:
		#print( state )
		_player_text( "But I was always good!", 2, 2, 19 )
	elif state == 19:
		#print( state )
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "face" )
		#_demon_text( "Not my problem!...", 2, 2, 20 )
		_demon_text( "It says here that...", 2, 2, 20 )
	elif state == 20:
		#print( state )
		# demon faces
		_demon_text( "You are condemned to Hell!!!", 3, 3, 21 )
	elif state == 21:
		#print( state )
		# player looks left
		player.look_behind()
		timer = 1
		state = -1
		state_nxt = 22
	elif state == 22:
		#print( state )
		# population increase
		get_node( "YSort/hell_sign/number" ).set_region_rect( Rect2( Vector2( 53, 5 ), Vector2( 3, 3 ) ) )
		get_node( "YSort/hell_sign/number/Particles2D" ).set_emitting( true )
		timer = 2
		state = -1
		state_nxt = 23
	elif state == 23:
		#print( state )
		# player looks right
		player.look_behind( false )
		_player_text( "Not much space here...", 2, 2, 24 )
	elif state == 24:
		#print( state )
		_demon_text( "We've been having some problems...", 2, 2, 25 )
	elif state == 25:
		#print( state )
		_demon_text( "... since Satan, left.", 2, 2, 26 )
	elif state == 26:
		#print( state )
		#_demon_text( "Would you be interested in a upworld job?", 3, 3, 27 )
		_demon_text( "And you can't stay here...", 2, 2, 27 )
	elif state == 27:
		#print( state )
		_player_text( "Where can I go?", 2, 2, 28 )
	elif state == 28:
		#print( state )
		_demon_text( "Go back to the world of the living.", 2, 2, 29 )
	elif state == 29:
		#print( state )
		_player_text( "Sounds good! What do I need to do?", 2, 3, 30 )
	elif state == 30:
		#print( state )
		_demon_text( "Slaughter as many demons as you can.", 3, 3, 31 )
	elif state == 31:
		#print( state )
		_demon_text( "That should bring them back home.", 3, 4, 39 )
	elif state == 32:
		#print( state )
		_player_text( "You don't know where Satan is?", 3, 3, 33 )
	elif state == 33:
		#print( state )
		_demon_text( "well... right! Do you take the job?", 2, 2, 34 )
	elif state == 34:
		#print( state )
		_player_text( "What do I get if I find him?", 2, 2, 35 )
	elif state == 35:
		#print( state )
		_demon_text( "hum... IF you find him...", 2, 2, 36 )
	elif state == 36:
		#print( state )
		_demon_text( "he might give you your life back.", 2, 2, 37 )
	elif state == 37:
		#print( state )
		_demon_text( "(GITHUB GAMEOFF JAM THEME...", 2, 2, 38 )
	elif state == 38:
		#print( state )
		_demon_text( "... restore previous characteristic)", 2, 2, 39 )
	elif state == 39:
		#print( state )
		#_player_text( "Heck... I'll take it", 2, 2, 40 )
		_player_text( "Yes... A demon slayer I shall be!", 2, 2, 46 )
	elif state == 40:
		#print( state )
		_demon_text( "Also...", 2, 2, 41 )
	elif state == 41:
		#print( state )
		_demon_text( "... you might find my bottom half...", 2, 2, 42 )
	elif state == 42:
		#print( state )
		_player_text( "eww...!", 1, 1, 43 )
	elif state == 43:
		#print( state )
		_demon_text( "yeah... Be a good demon...", 2, 2, 44 )
	elif state == 44:
		#print( state )
		_demon_text( "... and bring it back.", 2, 2, 45 )
	elif state == 45:
		#print( state )
		_player_text( "alright... I'll try.", 2, 2, 46 )
	elif state == 46:
		#print( state )
		# demon faces
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "game" )
		_demon_text( "Good! Up you go then...", 2, 3, 47 )
	elif state == 47:
		#player._set_fx_animation( player.ANIMATIONS_FX.LEAVE )
		player.arrive( false )
		timer = 3
		state = -1
		state_nxt = 48
	elif state == 48:
		player.hide()
		scene_1_end()
		state = 49

func scene_1_end():
	set_fixed_process( false )
	game.act_specific[0]["scene"] = 2
	if game.main != null:
		game.main.act_nxt = "res://scenes/act_2/act_2.tscn"




func _scene_2( delta ):
	if state == -1:
		# waiting state
		timer -= delta
		if timer <= 0:
			state = state_nxt
	elif state == 0:
		# demon plays games
		get_node( "YSort/blood_pool/demon" ).set_scale( Vector2( -1, 1 ) )
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "game" )
		# population 1
		get_node( "YSort/hell_sign/number" ).set_region_rect( Rect2( Vector2( 53, 1 ), Vector2( 3, 3 ) ) )
		# start a timer before begining
		timer = 2
		state = -1
		state_nxt = 1
	elif state == 1:
		# player arrives
		player.show()
		player.arrive()
		timer = 2
		state = -1
		state_nxt = 2
	elif state == 2:
		# player says hi
		_player_text( "Huh... Hello again...", 3, 2, 3 )
	elif state == 3:
		# demon looks at player
		get_node( "YSort/blood_pool/demon" ).set_scale( Vector2( 1, 1 ) )
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "face" )
		timer = 1
		state = -1
		state_nxt = 4
	elif state == 4:
		_demon_text( "So soon?", 2, 2, 5 )
	elif state == 5:
		_player_text( "I didn't stand a chance", 3, 3, 6 )
	elif state == 6:
		_demon_text( "Hum... You might need a weapon to fight.", 3, 3, 7 )
	elif state == 7:
		_demon_text( "Here... Take this!", 2, 2, 8 )
	elif state == 8:
		# place sword on player
		game.player_char = game.PLAYER_CHAR.HUMAN_SWORD
		state = 9
	elif state == 9:
		get_node( "swordparticles" ).set_emitting( true )
		timer = 2
		state = -1
		state_nxt = 10
	elif state == 10:
		_player_text( "huh... this... is... good...", 2, 2, 13 )
	elif state == 11:
		_player_text( "... I guess.", 2, 2, 12 )
	elif state == 12:
		_demon_text( "Also, I forgot to mention...", 2, 2, 13 )
	elif state == 13:
		_demon_text( "You may also transform into other demon forms.", 2, 2, 14 )
	elif state == 14:
		_player_text( "How do I do that?", 2, 2, 19 )
	elif state == 15:
		_demon_text( "Yes... You can't go back as a human...", 3, 3, 16 )
	elif state == 16:
		_demon_text( "And we're short on vampires up there.", 2, 3, 17 )
	elif state == 17:
		_player_text( "but... but...", 1, 1, 18 )
	elif state == 18:
		_demon_text( "Don't forget...", 2, 2, 19 )
	elif state == 19:
		_demon_text( "Just take some blood from their bodies.", 3, 3, 20 )
	elif state == 20:
		_player_text( "That's disgusting!", 1, 1, 21 )
	elif state == 21:
		# demon faces
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "game" )
		_demon_text( "Yes... Off you go!", 2, 2, 28 )
	elif state == 22:
		_player_text( "Wait!", 2, 2, 23 )
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "face" )
	elif state == 23:
		_player_text( "The other demons think I'm human!", 2, 2, 24 )
	elif state == 24:
		_demon_text( "Yes, yes... You don't look very vampiric yet", 2, 2, 25 )
	elif state == 25:
		_demon_text( "If you can't kill them...", 2, 2, 26 )
	elif state == 26:
		_demon_text( "... disguise yourself as a demon", 2, 2, 27 )
	elif state == 27:
		# demon faces
		get_node( "YSort/blood_pool/demon/anim_body" ).play( "game" )
		_demon_text( "Now go!", 1, 1, 28 )
	elif state == 28:
		player.arrive( false )
		timer = 3
		state = -1
		state_nxt = 29
	elif state == 29:
		scene_2_end()
		state = 30

func scene_2_end():
	set_fixed_process( false )
	game.act_specific[0]["scene"] = 3
	if game.main != null:
		game.main.act_nxt = "res://scenes/act_2/act_2.tscn"











func _player_text( msg, ttext, ttimer, nxt, voffset = -47 ):
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
func _demon_text( msg, ttext, ttimer, nxt, voffset = -47 ):
	var t = text_scn.instance()
	t.set_text( msg )
	t.add_color_override("font_color", Color(1,0,0))
	t.connect( "finished", self, "_on_text_finished" )
	t.connect( "interrupted", self, "_on_text_interrupted" )
	get_node( "YSort/blood_pool" ).add_child( t )
	t.set_offsetpos( Vector2( 20, voffset ) )
	t.set_timer( ttext )
	timer = ttimer
	state = -1
	state_nxt = nxt
	t = null


func _on_text_finished():
	pass
func _on_text_interrupted():
	timer = 0
