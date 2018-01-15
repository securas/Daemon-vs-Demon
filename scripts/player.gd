extends KinematicBody2D
#--------------------------
# signals
#--------------------------
signal is_dead
signal on_transformation
signal became_satan

#--------------------------
# scene state
#--------------------------
enum SCENE_STATES { CUTSCENE, NORMAL }
var scene_state_cur
var scene_state_nxt = SCENE_STATES.NORMAL
const TRANSFORMATION_DURATION = 10
#---------------------------------------
# input control
#---------------------------------------
var input_states = preload( "res://scripts/input_states.gd" )
var btn_left = input_states.new( "btn_left" )
var btn_right = input_states.new( "btn_right" )
var btn_up = input_states.new( "btn_up" )
var btn_down = input_states.new( "btn_down" )
var btn_fire = input_states.new( "btn_fire" )
var btn_pick = input_states.new( "btn_pick" )

#---------------------------------------
# motion control
#---------------------------------------
const MAX_VEL = Vector2( 80, 60 ) * 1.2
const ACCEL = Vector2( 10, 8 )
var vel = Vector2()

#---------------------------------------
# direction control
#---------------------------------------
onready var rotate = get_node( "rotate" )
onready var rotate_hitbox = get_node( "rotate_hitbox" )
var dir_cur = 0
var dir_nxt = 1

#---------------------------------------
# animation control
#---------------------------------------
onready var sprite_node = rotate.get_children()[0]
var _can_attack = true
var player_char = -1


#---------------------------------------
# manage attacks
#---------------------------------------
var sword_neighbours = []
var _is_dead_ = false
const ATTACK_INTERVAL = 2
var _attack_timer = 0


var _is_visible_to_enemies = false


#---------------------------------------
# external functions
#---------------------------------------
func set_cutscene( b = true ):
	if b:
		scene_state_nxt = SCENE_STATES.CUTSCENE
		sprite_node.set_animation( sprite_node.ANIMS.NONE )
	else:
		scene_state_nxt = SCENE_STATES.NORMAL

func look_behind( b = true ):
	if b:
		sprite_node.look_behind()
	else:
		sprite_node.look_forward()

func arrive( b = true ):
	if b:
		sprite_node.set_animation( sprite_node.ANIMS.ARRIVE )
		SoundManager.Play("p_teleport_in")
	else:
		sprite_node.set_animation( sprite_node.ANIMS.LEAVE )
		SoundManager.Play("p_teleport_out")

func is_dead():
	if not _is_visible_to_enemies: return true
	return _is_dead_

func die( source ):
	if _is_dead_: return false
	_is_dead_ = true
	hide()
	set_fixed_process( false )
	source.connect( "finished_kill", self, "_on_finished_kill_monster_1" )
	return true

#---------------------------------------
# ready
#---------------------------------------
var _is_ready = false
func _ready():
	if _is_ready:
		print( "ertererte" )
		return
	_is_ready = true
	# register
	game.player = weakref( self )
	
	# process
	set_fixed_process( true )




#---------------------------------------
# fixed process
#---------------------------------------
func _fixed_process( delta ):
	
	# check graphics
	if player_char != game.player_char:
		_update_character()
	# mode of operation
	scene_state_cur = scene_state_nxt
	if scene_state_cur == SCENE_STATES.CUTSCENE:
		_cutscene_state( delta )
	elif scene_state_cur == SCENE_STATES.NORMAL:
		_normal_state( delta )

	# check falling
	if _is_falling:
		#print( _falling_timer )
		_falling_timer -= delta
		if _falling_timer <= 0:
			set_cutscene()





func _cutscene_state( delta ):
	if _is_falling:
		# simulate falling
		vel.y += game.GRAVITY * delta
		vel.x = lerp( vel.x, 0, 3 * delta )
		var newpos = get_pos() + vel * delta
		sprite_node.set_opacity( lerp( sprite_node.get_opacity(), 0, 10*delta ) )
		set_pos( newpos )
		if newpos.y > 750:
			die( self )
			set_fixed_process( false )
			queue_free()
			emit_signal( "is_dead" )
			pass
	pass
	




func _normal_state( delta ):
	
	# player motion
	_player_motion( delta )
	
	# player attack
	_player_attack( delta )
	
	# pick up / interact
	_player_pick( delta )
	
	# motion
	vel = move_and_slide( vel )
	
	# direction
	_player_direction( delta )
	
	# timers
	#_attack_timer -= delta
	pass







func _player_motion( delta ):
	#print( "player motion" )
	if sprite_node.anim_finished():
		#print( "taking input" )
		var is_idle_x = false
		var is_idle_y = false
		var hit_dir = Vector2()
		if btn_left.check() == 2:
			vel.x = lerp( vel.x, -MAX_VEL.x, ACCEL.x * delta )
			sprite_node.set_animation( sprite_node.ANIMS.RUN )
			hit_dir.x = -MAX_VEL.x
		elif btn_right.check() == 2:
			vel.x = lerp( vel.x, MAX_VEL.x, ACCEL.x * delta )
			sprite_node.set_animation( sprite_node.ANIMS.RUN )
			hit_dir.x = MAX_VEL.x
		else:
			vel.x = lerp( vel.x, 0, 5 * ACCEL.x * delta )
			is_idle_x = true
			if vel.x < 5:
				vel.x = 0
		if btn_up.check() == 2:
			vel.y = lerp( vel.y, -MAX_VEL.y, ACCEL.y * delta )
			sprite_node.set_animation( sprite_node.ANIMS.RUN )
			hit_dir.y = -MAX_VEL.y
		elif btn_down.check() == 2:
			vel.y = lerp( vel.y, MAX_VEL.y, ACCEL.y * delta )
			sprite_node.set_animation( sprite_node.ANIMS.RUN )
			hit_dir.y = MAX_VEL.y
		else:
			vel.y = lerp( vel.y, 0, 5 * ACCEL.y * delta )
			is_idle_y = true
			if vel.y < 5:
				vel.y = 0
		if is_idle_x and is_idle_y:
			sprite_node.set_animation( sprite_node.ANIMS.IDLE )
			hit_dir = Vector2( dir_cur, 0 )
		if hit_dir.x < 0:
			hit_dir = -hit_dir
		elif hit_dir.x == 0 and dir_cur == -1:
			hit_dir.y = -hit_dir.y
		get_node("rotate_hitbox").set_rot( hit_dir.angle() - PI/2 )
	else:
		#print( "waiting for animation to finish" )
		#print( "anim: ", sprite_node.cur_anim )
		pass
	
	#get_node("rotate_hitbox").rotate(vel.angle())


#var _holding_timer = 0
#var _can_hold = true
func _player_attack( delta ):
	if btn_fire.check() == 1:
#		var can_attack = true
#		if _attack_timer <= 0:
#			# no recent attacks, can pick, if there is something to pick
#			var itemareas = get_node( "itembox" ).get_overlapping_areas()
#			if itemareas.size() > 0:
#				# there is stuff to pick
#				can_attack = false
#				_player_pick( itemareas )
#		if not sprite_node.anim_finished():
#			can_attack = false
		if sprite_node.anim_finished():#can_attack:
			sprite_node.set_animation( sprite_node.ANIMS.ATTACK )
			if player_char == game.PLAYER_CHAR.HUMAN_SWORD:
				#print( "Sword Neighbours" )
				#print( sword_neighbours )
				#print( "Overlapping areas" )
				#print( get_node( "rotate_hitbox/sword_hitbox" ).get_overlapping_areas() )
				if sword_neighbours.size() > 0:
					#_attack_timer = ATTACK_INTERVAL
					# kill neighbours
					var shake_camera = 0
					for n in sword_neighbours:
						if n.get_ref() != null:
							if n.get_ref().is_in_group( "monster" ):
								if not n.get_ref().is_dead() and _is_in_line_of_sight( n.get_ref() ):
									shake_camera += 1
									# apply force to monster during 0.2 seconds
									n.get_ref().set_external_force( \
											10000 * ( n.get_ref().get_global_pos() - get_global_pos() ).normalized(), \
											0.2 )
									# hit monster
									n.get_ref().get_hit( self )
								else:
									print( "neighb. dead or not in line of sight" )
							else:
								# this is a box, break it
								#print( "found a box" )
								var animnode = n.get_ref().get_node( "box/animate_box" )
								if animnode.get_current_animation() != "explode":
									animnode.play( "explode" )
									SoundManager.Play("inter_rockbox_hit")
									shake_camera += 1
						else:
							print( "rejected sword neighbour" )
					if shake_camera > 0:
						game.camera.get_ref().shake( 0.5, 30, min( 1.5 * shake_camera, 10 ) )
#
#	elif btn_fire.check() == 2 and _can_hold:
#		_holding_timer += delta
#		if _holding_timer >= 1.5:
#			_can_hold = false
#			_holding_timer = 0
#			# do stuff
#			var itemareas = get_node( "itembox" ).get_overlapping_areas()
#			if itemareas.size() > 0:
#				# there is stuff to pick
#				#can_attack = false
#				_player_pick( itemareas )
#			else:
#				# transform back to human
#				if game.player_char != game.PLAYER_CHAR.HUMAN_SWORD:
#					get_node( "transformation_timer" ).stop()
#					transform( game.PLAYER_CHAR.HUMAN_SWORD )
#	if not _can_hold:
#		_holding_timer += delta
#		if _holding_timer >= 1:
#			_holding_timer = 0
#			_can_hold = true



func _player_pick( delta ):
	if btn_pick.check() == 1:
		# check item areas
		var itemareas = get_node( "itembox" ).get_overlapping_areas()
		if itemareas.empty() > 0:
			# transform back to human
			if game.player_char != game.PLAYER_CHAR.HUMAN:
				if game.player_char != game.PLAYER_CHAR.HUMAN_SWORD:
					get_node( "transformation_timer" ).stop()
					transform( game.PLAYER_CHAR.HUMAN_SWORD )
		else:
			# there is stuff to pick
			vel *= 0
			sprite_node.set_animation( sprite_node.ANIMS.PICK )
			
			# must implement priorities... switch, doors or gates have priority!
			var item = itemareas[0]
			for area in itemareas:
				if area.is_in_group( "switch" ) or area.is_in_group( "tinydoor" ) or area.is_in_group( "gate" ):
					item = area
					break
			# picking only the first item
			#var item = itemareas[0]
			#print( item.get_groups() )
			if item.is_in_group( "blood" ):
				# transform
				if item.is_in_group( "monster_1" ):
					transform( game.PLAYER_CHAR.MONSTER_1 )
					emit_signal( "on_transformation" )
				elif item.is_in_group( "monster_2" ):
					transform( game.PLAYER_CHAR.MONSTER_2 )
					emit_signal( "on_transformation" )
				elif item.is_in_group( "monster_3" ):
					transform( game.PLAYER_CHAR.MONSTER_3 )
					emit_signal( "on_transformation" )
				elif item.is_in_group( "satan" ):
					transform( game.PLAYER_CHAR.SATAN )
					game.score += 1000
					emit_signal( "became_satan" )
				# emit signal
				#emit_signal( "on_transformation" )
				# start transformation timer
				if not item.is_in_group( "satan" ):
					get_node( "transformation_timer" ).set_wait_time( TRANSFORMATION_DURATION )
					get_node( "transformation_timer" ).start()
					
				#item.get_parent().queue_free()
			elif item.is_in_group( "switch" ):
				# flip switch
				item.get_parent().flip_switch()
			elif item.is_in_group( "tinydoor" ):
				# cross door
				item.cross_door()
			elif item.is_in_group( "gate" ):
				# open gate
				item.get_parent().open_gate()







func _player_direction( delta ):
	if vel.x > 0:
		dir_nxt = 1
	elif vel.x < 0:
		dir_nxt = -1
	if dir_nxt != dir_cur:
		dir_cur = dir_nxt
		rotate.set_scale( Vector2( dir_cur, 1 ) )
		rotate_hitbox.set_scale( Vector2( dir_cur, 1 ) )

func _update_character():
	sprite_node.queue_free()
	print( "loading sprite: ", game.CHAR_SCENES[game.player_char] )
	sprite_node = load( game.CHAR_SCENES[game.player_char] ).instance()
	rotate.add_child( sprite_node )
	player_char = game.player_char




func _on_sword_hitbox_area_enter( area ):
	if area.is_in_group( "damagebox" ):
		var obj = area.get_parent()
		if game.findweak( obj, sword_neighbours ) == -1:
			#print( "adding ", obj.get_name(), " to sword neighbours" )
			sword_neighbours.append( weakref( area.get_parent() ) )


func _on_sword_hitbox_area_exit( area ):
	if area.is_in_group( "damagebox" ):
		var obj = area.get_parent()
		var pos = game.findweak( obj, sword_neighbours )
		if pos != -1:
			#print( "removing ", obj.get_name(), " from sword neighbours" )
			sword_neighbours.remove( pos )


func _on_finished_kill_monster_1():
	queue_free()
	emit_signal( "is_dead" )



func transform( newchar ):
	if newchar == game.player_char: return
	#print( "transforming" )
	game.player_char = newchar
	#effects
	get_node( "transformation_particles" ).set_emitting( true )
	# rules for each character
	if newchar == game.PLAYER_CHAR.MONSTER_1:
		# remove layers
		set_collision_mask_bit( 0, false )
		set_layer_mask_bit( 0, false )
		get_node( "rotate_hitbox/falling_area" ).set_collision_mask_bit( 19, false )
		get_node( "rotate_hitbox/falling_area" ).set_layer_mask_bit( 19, false )
	elif newchar == game.PLAYER_CHAR.MONSTER_2:
		# remove layers
		pass
	elif newchar == game.PLAYER_CHAR.MONSTER_3:
		# remove layers
		pass
	elif newchar == game.PLAYER_CHAR.HUMAN_SWORD:
		# add layers
		set_collision_mask_bit( 0, true )
		set_layer_mask_bit( 0, true )
		get_node( "rotate_hitbox/falling_area" ).set_collision_mask_bit( 19, true )
		get_node( "rotate_hitbox/falling_area" ).set_layer_mask_bit( 19, true )
	
	pass





var _is_falling = false
var _falling_timer = 0
func _on_falling_area_area_enter( area ):
	if _is_falling: return
	if area.is_in_group( "fall_area" ):
		game.camera_target = null
		_is_falling = true
		vel *= 0
		#if area.is_in_group( "up_fall" ):
		#	set_z( -1 )
		_falling_timer = 0.25
		#set_cutscene()
		


func _on_falling_area_area_exit( area ):
	if _falling_timer > 0:
		_is_falling = false
		game.camera_target = game.player
		sprite_node.set_opacity(1)
		set_z( 0 )







func _on_transformation_timer_timeout():
	transform( game.PLAYER_CHAR.HUMAN_SWORD )

var particle_attractor_path = ""
func _on_keybox_area_enter( area ):
	if area.is_in_group( "key" ):
		# play picking animation
		area.get_parent().get_node( "key/animate_key" ).play( "pick" )
		game.has_key = true
		game.score += 200
	elif area.is_in_group( "coin" ):
		# play picking animation
		area.get_parent().get_node( "key/animate_key" ).play( "pick" )
		# add to score
		game.score += 100



func _is_in_line_of_sight( obj ):
	var space_state = get_world_2d().get_direct_space_state()
	var results = space_state.intersect_ray( get_global_pos(), obj.get_global_pos(), [ self ], 2147483647, 1 )
	if results.empty(): return true
#	if not results.empty() and results["collider"] == obj:
#		# we can see the player, not check
#		return true
	#print( "not in line of sight" )
	return false

func _on_visibility_to_enemies_timer_timeout():
	_is_visible_to_enemies = true
