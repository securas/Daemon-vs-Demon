extends KinematicBody2D

enum STATES { IDLE, ATTACK, DEAD }
enum ATTACK_STATES { SEARCH, SHOOT, SEEK }

const SHOOTING_RANGE = 50


var steering_control = preload( "res://scripts/steering.gd" ).new()
var navigator = null
var navigation_timer = 0
const NAVIGATION_INTERVAL = 1
var neighbours = []
var vel = Vector2()
var target_path = []
var external_impulse = Vector2()
var external_impulse_timer = 0


const SHOOTING_INTERVAL = 1
var _is_shooting = false
var shooting_state = 0
var shooting_state_nxt = 0
var shooting_timer = 0

var state_cur = -1
var state_nxt = STATES.ATTACK
var attack_state_cur = -1
var attack_state_nxt = ATTACK_STATES.SEARCH

onready var anim = get_node( "anim" )
var anim_nxt = "idle"
var anim_cur = ""

onready var rotate = get_node( "rotate" )
var dir_cur = 1
var dir_nxt = 1

func _ready():
	steering_control.max_vel = 50
	steering_control.max_force = 500
	set_fixed_process( true )
	game.player_char = game.PLAYER_CHAR.MONSTER_1



# External functions
func is_dead():
	return false





func _fixed_process( delta ):
	state_nxt = STATES.ATTACK
	
	state_cur = state_nxt
	if state_cur == STATES.IDLE:
		_state_idle( delta )
	elif state_cur == STATES.ATTACK:
		_state_attack( delta )
	elif state_cur == STATES.DEAD:
		_state_dead( delta )
	
	# animation
	if anim_nxt != anim_cur:
		anim_cur = anim_nxt
		anim.play( anim_cur )
	
	# direction
	if dir_nxt != dir_cur:
		dir_cur = dir_nxt
		rotate.set_scale( Vector2( dir_cur, 1 ) )


func _state_idle( delta ):
	# do nothing
	pass

func _state_attack( delta ):
	attack_state_cur = attack_state_nxt
	var steering_force = Vector2()
	var flocking_force = Vector2()
	var target_pos = null
	
	if _get_player():
		# check if player is within shooting range
		if _player_in_shooting_range() and not _is_shooting:
			# shoot
			_is_shooting = true
			shooting_state = 0
			#shooting_timer = SHOOTING_INTERVAL
			#var shooting_dir = game.player.get_ref().get_global_pos() - get_global_pos()
			#external_impulse = -shooting_dir.normalized() * 3000
			#external_impulse_timer = 0.1
			pass
		# check navigation
		navigation_timer -= delta
		if navigation_timer <= 0:
			navigation_timer = NAVIGATION_INTERVAL
			target_path = _get_path_towards( game.player.get_ref().get_global_pos() )
	else:
		navigation_timer = 0
	
	if _is_shooting:
		# shooting fsm
		if _shooting_fsm( delta ):
			_is_shooting = false
		# dampening
		vel *= 0.60
	else:
		# steering forces
		if not target_path.empty():
			target_pos = target_path[0]
			steering_force = steering_control.steering_and_arriving( \
					get_global_pos(), target_pos, 
					vel, 10, delta )
		# flocking forces
		flocking_force = steering_control.flocking( \
					self, neighbours, 10000, 1, 1 )
		# dampening
		vel *= 0.98
		# force and velocity
		var force = steering_force + flocking_force
		force = steering_control.truncate( force, steering_control.max_force )
		vel += force * delta
		vel = steering_control.truncate( vel, steering_control.max_vel )
		
		if vel.length_squared() < 16:
			vel *= 0
		else:
			anim_nxt = "run"
		# direction
		if vel.x > 0:
			dir_nxt = 1
		elif vel.x < 0:
			dir_nxt = -1
	
	# external forces
	vel += external_impulse * delta
	external_impulse_timer -= delta
	if external_impulse_timer <= 0:
		external_impulse = Vector2()
	
	# motion
	vel = move_and_slide( vel )
	
	# check if near target position
	if target_pos != null and ( target_pos - get_global_pos() ).length() < 20:
		target_path.pop_back()
	pass


func _state_dead( delta ):
	pass




func _shooting_fsm( delta ):
	if shooting_state == -1:
		shooting_timer -= delta
		if shooting_timer <= 0:
			shooting_state = shooting_state_nxt
	elif shooting_state == -2:
		#continuous aiming
		# direction
		var shooting_dir = game.player.get_ref().get_global_pos() - get_global_pos()
		if shooting_dir.x > 0: dir_nxt = 1
		else: dir_nxt = -1
		shooting_timer -= delta
		if shooting_timer <= 0:
			shooting_state = shooting_state_nxt
	elif shooting_state == 0:
		
		var player = _get_player()
		if player != null:
			# aim
			anim_nxt = "aim"
			# stop moving
			vel *= 0
		
			shooting_timer = 0.5
			shooting_state_nxt = 1
			shooting_state = -2
		else:
			anim_nxt = "idle"
			return true
	elif shooting_state == 1:
		
		var player = _get_player()
		if player != null:
			# fire
			anim_nxt = "fire"
			# direction of bullet
			var shooting_dir = game.player.get_ref().get_global_pos() - get_global_pos()
			# external impulse
			external_impulse = -shooting_dir.normalized() * 10000
			external_impulse_timer = 0.05
			# bullet object
			
			# running dust
			var dust = preload( "res://scenes/running_dust.tscn" ).instance()
			dust.set_pos( get_pos() + dir_cur * Vector2( 0, 0 ) )
			dust.set_scale( Vector2( -dir_cur, 1 ) )
			get_parent().add_child( dust )
			
			shooting_timer = 0.5
			shooting_state_nxt = 2
			shooting_state = -1
		else:
			anim_nxt = "idle"
			return true
	elif shooting_state == 2:
		# restore
		anim_nxt = "idle"
		shooting_timer = 1
		shooting_state_nxt = 3
		shooting_state = -1
	elif shooting_state == 3:
		# report finished
		return true
	return false



func _get_player():
	if ( game.player_char != game.PLAYER_CHAR.HUMAN and \
				game.player_char != game.PLAYER_CHAR.HUMAN_SWORD and \
				game.player_char != game.PLAYER_CHAR.HUMAN_GUN ) and \
				game.player != null and game.player.get_ref() != null and \
				( not game.player.get_ref().is_dead() ):
		return game.player.get_ref()
	return null


func _player_in_shooting_range():
	# check distance to player
	var distance = game.player.get_ref().get_global_pos() - get_global_pos()
	if distance.length() > SHOOTING_RANGE:
		return false
	# check angle with respect to player
	#var ang_dist = Vector2( abs( distance.x ), abs( distance.y ) )
	#if ( ang_dist.angle() - PI / 2 ) > ( SHOOTING_ANGLE_RANGE * PI / 180 ):
	#	return false
	# player is in reach and within the angle range
	# check if its in line of sight
	if _in_line_of_sight( game.player.get_ref() ):
		return true
	return false

func _in_line_of_sight( player ):
	var space_state = get_world_2d().get_direct_space_state()
	var results = space_state.intersect_ray( get_global_pos(), game.player.get_ref().get_global_pos(), [ self ] )
	if not results.empty() and results["collider"] == game.player.get_ref():
		# we can see the player
		return true
	return false



func _get_path_towards( pos ):
	return [pos]
	# check if position is reachable directly
	var space_state = get_world_2d().get_direct_space_state()
	# check for static bodies on the way
	var results = space_state.intersect_ray( get_global_pos(), pos, [ self ], 2147483647, 1 )
	if results.empty():
		# we can see the player
		return [pos]
	# there is no direct sight... try to navigate towards player
	if navigator == null:
		return []
	pass




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

