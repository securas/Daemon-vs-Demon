extends KinematicBody2D

signal boss_dying
signal boss_dead


const BULLET_COUNT = 3
const ATTACK_TIME = 4
const MAX_HITS = 1
var hits = 0



export( NodePath ) var navigation_nodepath
var navigation = null
var navcontrol_script = preload( "res://scripts/timed_navigation.gd" )
var navcontrol
var steering_control = preload( "res://scripts/steering.gd" ).new()
var vel = Vector2( 0, 0 )
var external_impulse = Vector2()
var external_impulse_timer = 0

enum STATES { IDLE, ATTACK_SLASH, WAIT, ATTACK_BULLET, DYING, DEAD }
var state_cur = -1
var state_nxt = STATES.IDLE

onready var anim = get_node( "anim" )
var anim_nxt = "idle"
var anim_cur = ""

onready var rotate = get_node( "rotate" )
var dir_cur = 1
var dir_nxt = 1

func is_dead():
	if state_cur == STATES.DEAD or state_cur == STATES.DYING:
		return true
	return false
#---------------------------------------
# function called when the monster is hit by the hittin source
#---------------------------------------
func get_hit( source ):
	if state_cur != STATES.DEAD and state_cur != STATES.DYING:
		hits += 1
		if hits >= MAX_HITS:
			# monster dies immediately
			state_nxt = STATES.DYING
		return true
	return false
#---------------------------------------
# function called to apply external force
#---------------------------------------
func set_external_force( force, duration ):
	if state_cur != STATES.DEAD and state_cur != STATES.DYING:
		# create force
		external_impulse_timer = duration
		external_impulse = force
		# create blood splatter
		var blood = preload( "res://scenes/blood_particles.tscn" ).instance()
		blood.set_pos( get_pos() )
		blood.set_rot( external_impulse.angle() )
		get_parent().add_child( blood )





func _ready():
	# navigation
	if navigation_nodepath != null:
		navigation = get_node( navigation_nodepath )
	navcontrol = navcontrol_script.new( 1, navigation )
	# steering
	steering_control.max_vel = 100
	steering_control.max_force = 1000
	
	set_fixed_process( true )


func _fixed_process( delta ):
	state_cur = state_nxt
	if state_cur == STATES.IDLE: _state_idle( delta )
	elif state_cur == STATES.ATTACK_SLASH: _state_attack_slash( delta )
	elif state_cur == STATES.WAIT: _state_wait( delta )
	elif state_cur == STATES.ATTACK_BULLET: _state_attack_bullet( delta )
	elif state_cur == STATES.DYING: _state_dying( delta )
	elif state_cur == STATES.DEAD: _state_dead( delta )
	
	if anim_nxt != anim_cur:
		anim_cur = anim_nxt
		anim.play( anim_cur )
	
	if dir_nxt != dir_cur:
		dir_cur = dir_nxt
		rotate.set_scale( Vector2( dir_cur, 1 ) )



func _state_idle( delta ):
	anim_nxt = "idle"
	# wait until boss fight
	if not game.boss_fight: return
	
	# check if player is in view
	if _get_player():
		
		var target_pos = navcontrol.get_path_towards( \
					get_global_pos(), \
					game.player.get_ref().get_global_pos(), delta )
		if target_pos != null:
			if ( game.player.get_ref().get_global_pos() - get_global_pos() ).length() < 100:
				state_nxt = STATES.ATTACK_SLASH
			else:
				state_nxt = STATES.ATTACK_BULLET
		
		# external forces
		vel *= 0.7
		_move_with_external( delta )


var _attack_slash_timer = ATTACK_TIME
func _state_attack_slash( delta ):
	_attack_slash_timer -= delta
	if _attack_slash_timer <= 0:
		_attack_slash_timer = ATTACK_TIME
		anim_nxt = "idle"
		_wait_time = 1
		_after_wait_state = STATES.ATTACK_BULLET
		state_nxt = STATES.WAIT
	if _get_player() == null:
		state_nxt = STATES.IDLE
		return
	
	var steering_force = Vector2()
	
	# steer towards player
	var target_pos = navcontrol.get_path_towards( \
			get_global_pos(), \
			game.player.get_ref().get_global_pos() + game.player.get_ref().vel * delta, delta )
	if target_pos == null:
		state_nxt = STATES.IDLE
	else:
		steering_force = steering_control.steering_and_arriving( \
				get_global_pos(), target_pos, 
				vel, 10, delta )
		vel += steering_force * delta
		vel = steering_control.truncate( vel, steering_control.max_vel )
		# direction
		if vel.x > 0:
			dir_nxt = 1
		elif vel.x < 0:
			dir_nxt = -1
		# animation
		anim_nxt = "run"
		
		# motion
		_move_with_external( delta )
		# slash
		var dist = game.player.get_ref().get_global_pos() - get_global_pos()
		if dist.length() < 10:
			# slash
			anim_nxt = "slash"
			# wait until finish slashing
			_wait_time = 1
			_after_wait_state = STATES.ATTACK_BULLET
			state_nxt = STATES.WAIT
			pass


var _wait_time = 0
var _after_wait_state = -1
func _state_wait( delta ):
	_wait_time -= delta
	if _wait_time <= 0:
		state_nxt = _after_wait_state
	# external forces
	vel *= 0.7
	vel += external_impulse * delta
	external_impulse_timer -= delta
	if external_impulse_timer <= 0:
		external_impulse = Vector2()
	# motion
	vel = move_and_slide( vel )


var bullet_count = BULLET_COUNT
func _state_attack_bullet( delta ):
	if _get_player() == null:
		state_nxt = STATES.IDLE
		return
	
	var target_pos = navcontrol.get_path_towards( \
			get_global_pos(), \
			game.player.get_ref().get_global_pos() + game.player.get_ref().vel * delta, delta )
	if target_pos == null:
		state_nxt = STATES.IDLE
	else:
		print( "firing: ", bullet_count )
		anim_nxt = "fire"
		bullet_count -= 1
		
		
		if bullet_count > 0:
			_wait_time = 1.5
			_after_wait_state = STATES.ATTACK_BULLET
		else:
			bullet_count = BULLET_COUNT
			_wait_time = 2
			_after_wait_state = STATES.ATTACK_SLASH
		state_nxt = STATES.WAIT
	# direction
	var sd = game.player.get_ref().get_global_pos().x - get_global_pos().x
	if sd > 0:
		dir_nxt = 1
	elif sd < 0:
		dir_nxt = -1
	# motion
	vel *= 0.7
	_move_with_external( delta )


var _dying_wait = false
func _state_dying( delta ):
	if not _dying_wait:
		anim_nxt = "dying"
		_dying_wait = true
		emit_signal( "boss_dying" )
	pass

var _dead_wait = false
func _state_dead( delta ):
	anim_nxt = "dead"
	if not _dead_wait:
		_dead_wait = true
		print( "boss dead" )
		emit_signal( "boss_dead" )
	pass


func _move_with_external( delta ):
	# external forces
	vel += external_impulse * delta
	external_impulse_timer -= delta
	if external_impulse_timer <= 0:
		external_impulse = Vector2()
	# motion
	vel = move_and_slide( vel )






func _get_player():
	if ( game.player_char == game.PLAYER_CHAR.HUMAN or \
				game.player_char == game.PLAYER_CHAR.HUMAN_SWORD or \
				game.player_char == game.PLAYER_CHAR.HUMAN_GUN ) and \
				game.player != null and game.player.get_ref() != null and \
				( not game.player.get_ref().is_dead() ):
		return game.player.get_ref()
	return null



var _predict_player = true
func _on_fire_bullet():
	if _get_player() != null:
		var bullet = preload( "res://scenes/monster_bullet.tscn" ).instance()
		
		var playerpos = game.player.get_ref().get_global_pos()
		var shootingpos = get_global_pos()
		if _predict_player:
				var dir0 = playerpos - shootingpos
				var timetotarget = dir0.length() / bullet.VEL + 0.5 # includes animation time
				var newplayerpos = playerpos + game.player.get_ref().vel * timetotarget
				if ( playerpos - newplayerpos ).length() < 10:
					playerpos = newplayerpos
		var shooting_dir = ( playerpos - shootingpos ).normalized()
		
		bullet.set_pos( get_pos() + Vector2( 15 * dir_cur, -15 ) )
		bullet.dir = shooting_dir.normalized()
		get_parent().add_child( bullet )
	return
	# external impulse
	#external_impulse = -shooting_dir.normalized() * 10000
	#external_impulse_timer = 0.05
	# instance bullet
	"""
	var bullet = preload( "res://scenes/monster_bullet.tscn" ).instance()
	bullet.set_pos( get_pos() + Vector2( 15 * dir_cur, 0 ) )
	bullet.dir = shooting_dir.normalized()
	get_parent().add_child( bullet )
"""



func _running_dust():
	var dust = preload( "res://scenes/running_dust.tscn" ).instance()
	dust.set_pos( get_pos() + dir_cur * Vector2( 5, 0 ) )
	dust.set_scale( Vector2( dir_cur, 1 ) )
	#print( get_parent().get_parent().get_parent().get_name() )
	get_parent().add_child( dust )

func _on_anim_finished():
	if state_cur != STATES.DYING and state_cur != STATES.DEAD:
		anim_nxt = "idle"
	pass # replace with function body
