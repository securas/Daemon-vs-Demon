extends KinematicBody2D
#const SHOOTING_RANGE = 50
const RANGE_RECT = Rect2( Vector2( 0, -15 ), Vector2( 130, 30 ) )
enum STATES { IDLE, WANDER, ATTACK, DEAD }
var state_cur = -1
var state_nxt = STATES.IDLE

var steering_control = preload( "res://scripts/steering.gd" ).new()
var neighbours = []
var vel = Vector2( 0, 0 )
var external_impulse = Vector2()
var external_impulse_timer = 0

onready var anim = get_node( "anim" )
var anim_cur = ""
var anim_nxt = "idle"

onready var rotate = get_node( "rotate" )
var dir_nxt = 1
var dir_cur = 1


func is_dead():
	if state_cur == STATES.DEAD:
		return true
	return false





func _ready():
	steering_control.max_vel = 50
	steering_control.max_force = 500
	set_fixed_process( true )


func _fixed_process( delta ):
	state_cur = state_nxt
	
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
	pass

enum ATTACK_STATES { IDLE, SEEK, SHOOT }
var attack_state = ATTACK_STATES.SEEK
var attack_timer = 0
var shooting_dir = Vector2()
func _attack_fsm( delta ):
	#print( "attack state: ", attack_state )
	var steering_force = Vector2()
	var flocking_force = Vector2()
	var target_pos = null
	
	if attack_state == ATTACK_STATES.IDLE:
		#print( "waiting" )
		vel *= 0
		attack_timer -= delta
		if attack_timer <= 0:
			attack_state = ATTACK_STATES.SEEK
	elif attack_state == ATTACK_STATES.SEEK:
		# move towards player
		if _get_player():
			if _player_in_shooting_range():
				# start shooting
				attack_state = ATTACK_STATES.SHOOT
				print( "shooting" )
			else:
				var target_path = _get_path_towards( game.player.get_ref().get_global_pos() )
				if not target_path.empty():
					steering_force = steering_control.steering_and_arriving( \
							get_global_pos(), target_path[0], 
							vel, 10, delta )
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
				self, neighbours, 10000, 1, 1 )
	
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
			shooting_dir = game.player.get_ref().get_global_pos() - get_global_pos()
	
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
	










func _get_path_towards( pos ):
	return [pos]

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