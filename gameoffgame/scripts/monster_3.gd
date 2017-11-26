extends KinematicBody2D
export( NodePath ) var navigation_nodepath
var navigation = null
var navcontrol_script = preload( "res://scripts/timed_navigation.gd" )
var navcontrol

const RANGE_RECT = Rect2( Vector2( 0, -15 ), Vector2( 130, 30 ) )
enum STATES { IDLE, WANDER, ATTACK, DEAD }
var state_cur = -1
var state_nxt = STATES.ATTACK

var steering_control = preload( "res://scripts/steering.gd" ).new()
var neighbours = []
var vel = Vector2( 0, 0 )
var external_impulse = Vector2()
var external_impulse_timer = 0
onready var starting_pos = get_global_pos()
var _is_falling = false

onready var anim = get_node( "anim" )
var anim_cur = ""
var anim_nxt = "idle"

onready var rotate = get_node( "rotate" )
var dir_nxt = 1
var dir_cur = 1

func play_event(event):
	SoundManager.Play(event)

#---------------------------------------
# function to check if dead
#---------------------------------------
func is_dead():
	if state_cur == STATES.DEAD:
		return true
	return false
#---------------------------------------
# function called when the monster is hit by the hittin source
#---------------------------------------
func get_hit( source ):
	if state_cur != STATES.DEAD and state_nxt != STATES.DEAD:
		# monster dies immediately
		state_nxt = STATES.DEAD
		SoundManager.Play("p_sword_hit")
		SoundManager.Play("en_gore")
		game.score += 200
		return true
	return false
#---------------------------------------
# function called to apply external force
#---------------------------------------
func set_external_force( force, duration ):
	if state_cur != STATES.DEAD and state_nxt != STATES.DEAD:
		# create force
		external_impulse_timer = duration
		external_impulse = force
		# create blood splatter
		var blood = preload( "res://scenes/blood_particles.tscn" ).instance()
		blood.set_pos( get_pos() )
		blood.set_rot( external_impulse.angle() )
		get_parent().add_child( blood )
		SoundManager.Play("en_gore")



func _ready():
	if navigation_nodepath != null and not navigation_nodepath.is_empty():
		navigation = get_node( navigation_nodepath )
	navcontrol = navcontrol_script.new( 1, navigation )
	
	steering_control.max_vel = 70#100
	steering_control.max_force = 700#1000
	set_fixed_process( true )


func _fixed_process( delta ):
	state_cur = state_nxt
	#state_cur = STATES.IDLE
	
	if state_cur == STATES.IDLE:
		pass
	elif state_cur == STATES.WANDER:
		pass
	elif state_cur == STATES.ATTACK:
		_attack_fsm( delta )
	elif state_cur == STATES.DEAD:
		_dead_fsm( delta )
	
	if anim_nxt != anim_cur:
		#print( "animation: ", anim_nxt )
		anim_cur = anim_nxt
		anim.play( anim_cur )
	
	if dir_nxt != dir_cur:
		dir_cur = dir_nxt
		rotate.set_scale( Vector2( dir_cur, 1 ) )



func _dead_fsm( delta ):
	# set death animation
	anim_nxt = "dead"
	# check if falling
	if not _is_falling:
		#print( "not falling" )
		var uplow = game.check_fall_area( self, get_global_pos() )
		if uplow == 1:
			_is_falling = true
			#set_z( -1 )
		elif uplow == -1:
			_is_falling = true
		# dampening
		vel *= 0.5
		if vel.length_squared() < 4:
				vel *= 0.0
	else:
		vel.x *= 0.5
		vel.y = min( vel.y + delta * game.GRAVITY, game.TERMINAL_VEL )
		if get_global_pos().y > 700:
			set_fixed_process( false )
			_change_to_item()
	# external forces
	vel += external_impulse * delta
	external_impulse_timer -= delta
	if external_impulse_timer <= 0:
		external_impulse = Vector2()
	# motion
	vel = move_and_slide( vel )
	
	pass





enum ATTACK_STATES { IDLE, SEEK, SHOOT }
var attack_state = ATTACK_STATES.IDLE
var attack_timer = 0
var shooting_dir = Vector2()
func _attack_fsm( delta ):
	var steering_force = Vector2()
	var flocking_force = Vector2()
	var target_pos = null
	if _get_player():
		target_pos = navcontrol.get_path_towards( \
					get_global_pos(), \
					game.player.get_ref().get_global_pos(), delta )
	
	if attack_state == ATTACK_STATES.IDLE:
		if game.player != null and game.player.get_ref() != null:
			if game.player.get_ref().is_dead():
				navcontrol = navcontrol_script.new( 1, navigation )
		if target_pos != null:
			print( get_name(), ": found player... seeking" )
			attack_state = ATTACK_STATES.SEEK
		else:
			# navigate towards starting position
			steering_force = steering_control.steering_and_arriving( \
					get_global_pos(), starting_pos, 
					vel, 10, delta )
			# direction
			if vel.x > 0:
				dir_nxt = 1
			elif vel.x < 0:
				dir_nxt = -1
		
		
	elif attack_state == ATTACK_STATES.SEEK:
		# move towards player
		if _get_player():
			if _player_in_shooting_range():
				attack_state = ATTACK_STATES.SHOOT
				SoundManager.Play("en_orb_atk_grow")
				#print( "shooting" )
			else:
				if target_pos != null:
					steering_force = steering_control.steering_and_arriving( \
							get_global_pos(), target_pos, 
							vel, 10, delta )
				else:
					#navcontrol = navcontrol_script.new( 1, navigation )
					#print( "cannot find player" )
					attack_state = ATTACK_STATES.IDLE
		else:
			#navcontrol = navcontrol_script.new( 1, navigation )
			#print( "cannot get player" )
			attack_state = ATTACK_STATES.IDLE
		# dampening
		vel *= 0.98
		# direction
		if vel.x > 0:
			dir_nxt = 1
		elif vel.x < 0:
			dir_nxt = -1
		
		
	elif attack_state == ATTACK_STATES.SHOOT:
		anim_nxt = "fire"
		# dampening
		vel *= 0.9
	
	
	
	
	# flocking forces
	if attack_state != ATTACK_STATES.SHOOT:
		flocking_force = steering_control.flocking( \
				self, neighbours, 5000, 1, 1 )
	
	# force and velocity
	#print( steering_force, " ", flocking_force )
	var force = steering_force + flocking_force
	force = steering_control.truncate( force, steering_control.max_force )
	vel += force * delta
	vel = steering_control.truncate( vel, steering_control.max_vel )
	
	# external forces
	vel += external_impulse * delta
	external_impulse_timer -= delta
	if external_impulse_timer <= 0:
		external_impulse = Vector2()
	
	if vel.length_squared() < 16:
		vel *= 0
		if attack_state != ATTACK_STATES.SHOOT:
			anim_nxt = "idle"
	else:
		if attack_state != ATTACK_STATES.SHOOT:
			anim_nxt = "run"
			shooting_dir = game.player.get_ref().get_global_pos() - ( get_global_pos() + Vector2( 15 * dir_cur, 0 ) )
	
	# motion
	vel = move_and_slide( vel )



func _on_finished_firing():
	attack_timer = 1
	attack_state = ATTACK_STATES.IDLE

func _on_fire_bullet():
	# external impulse
	external_impulse = -shooting_dir.normalized() * 10000
	external_impulse_timer = 0.05
	# instance bullet
	var bullet = preload( "res://scenes/monster_bullet.tscn" ).instance()
	bullet.set_pos( get_pos() + Vector2( 15 * dir_cur, 0 ) )
	bullet.dir = shooting_dir.normalized()
	get_parent().add_child( bullet )
	

func _on_finished_dying():
	set_fixed_process( false )
	_change_to_item()








func _get_path_towards( pos ):
	return Vector2Array( [ pos ] )
	if navigation == null:
		return [pos]
	var varr = navigation.get_simple_path( get_global_pos(), pos )
	print( varr )
	var path = []
	for v in varr: path.append( v )
	return path

func _player_in_shooting_range():
	# check distance to player
	var distance = game.player.get_ref().get_global_pos() - get_global_pos()
	var range_rect = RANGE_RECT
	range_rect.pos += get_global_pos()
	if dir_cur < 0:
		range_rect.pos.x -= range_rect.size.x
	
	if not range_rect.has_point( game.player.get_ref().get_global_pos() ):
		return false
	# player is in reach and within the angle range
	# check if its in line of sight
	if _in_line_of_sight( game.player.get_ref() ):
		return true
	return false

func _in_line_of_sight( player ):
	var space_state = get_world_2d().get_direct_space_state()
	var results = space_state.intersect_ray( get_global_pos(), game.player.get_ref().get_global_pos(), [ self ] )
	if not results.empty() and results["collider"] == game.player.get_ref():
		# we can see the player, not check
		return true
	return false

func _get_player():
	if ( game.player_char == game.PLAYER_CHAR.HUMAN or \
				game.player_char == game.PLAYER_CHAR.HUMAN_SWORD or \
				game.player_char == game.PLAYER_CHAR.HUMAN_GUN ) and \
				game.player != null and game.player.get_ref() != null and \
				( not game.player.get_ref().is_dead() ):
		return game.player.get_ref()
	return null

func _on_flocking_area_enter( area ):
	var obj = area.get_parent()
	if obj.is_in_group( "monster" ):
		if game.findweak( obj, neighbours ) == -1:
			neighbours.append( weakref( obj ) )



func _on_flocking_area_exit( area ):
	var obj = area.get_parent()
	if obj.is_in_group( "monster" ):
		var pos = game.findweak( obj, neighbours )
		if pos != -1:
			neighbours.remove( pos )

func _running_dust():
	var dust = preload( "res://scenes/running_dust.tscn" ).instance()
	dust.set_pos( get_pos() + dir_cur * Vector2( 5, 0 ) )
	dust.set_scale( Vector2( dir_cur, 1 ) )
	#print( get_parent().get_parent().get_parent().get_name() )
	get_parent().add_child( dust )

var _changed_to_item = false
func _change_to_item():
	if _changed_to_item: return
	_changed_to_item = true
	#print( "changing to item" )
	# delete unecessary nodes
	#get_node( "anim" ).queue_free()
	get_node( "flocking/CollisionShape2D" ).queue_free()
	get_node( "flocking" ).queue_free()
	get_node( "damagebox/CollisionShape2D" ).queue_free()
	get_node( "damagebox" ).queue_free()
	get_node( "collision" ).queue_free()
	
	# change mask of kinematic body
	set_layer_mask_bit( 1, false )
	set_collision_mask_bit( 1, false )
	# change mask of item box
	get_node( "itemarea" ).set_layer_mask_bit( 2, true )
	get_node( "itemarea" ).set_collision_mask_bit( 2, true )