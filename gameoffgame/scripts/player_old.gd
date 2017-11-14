extends KinematicBody2D

# signals
signal is_dead

#---------------------------------------
# input control
#---------------------------------------
var input_states = preload( "res://scripts/input_states.gd" )
var btn_left = input_states.new( "btn_left" )
var btn_right = input_states.new( "btn_right" )
var btn_up = input_states.new( "btn_up" )
var btn_down = input_states.new( "btn_down" )
var btn_fire = input_states.new( "btn_fire" )

#---------------------------------------
# motion control
#---------------------------------------
const MAX_VEL = Vector2( 80, 50 )
const ACCEL = Vector2( 10, 8 )
var vel = Vector2()

#---------------------------------------
# scene control
#---------------------------------------
var _in_cutscene = false

#---------------------------------------
# animation control
#---------------------------------------
enum ANIMATIONS_BODY { NONE, IDLE, WALK, RUN, \
		SWORD_UP, SWORD_DOWN, \
		SWORD_UP_IDLE, SWORD_DOWN_IDLE, \
		SLICE_UP, SLICE_DOWN }
enum ANIMATIONS_LEGS { IDLE, WALK, RUN }
onready var anim_body = get_node( "anim_body" )
onready var anim_legs = get_node( "anim_legs" )
var anim_legs_cur = -1
var anim_legs_nxt = ANIMATIONS_LEGS.IDLE
var anim_body_cur = -1
var anim_body_nxt = ANIMATIONS_BODY.NONE
var anim_body_state = 0
var _waiting_for_animation = false


#---------------------------------------
# direction control
#---------------------------------------
onready var rotate = get_node( "rotate" )
onready var rotate_head = get_node( "rotate/body/rotate_head" )
var dir_cur = 0
var dir_nxt = 1
var dir_head_cur = 0
var dir_head_nxt = 1 # 1 is to match body and -1 is to look back

func _ready():
	# register with game
	game.player = weakref( self )
	game.player_spawnpos = get_pos()
	if game.player_weapon == game.WEAPONS.NONE:
		anim_body_state = 0
	elif game.player_weapon == game.WEAPONS.SWORD:
		anim_body_state = 1
	set_fixed_process( true )

var _starting_animation = true
var _is_starting = false
var starting_timer = 2
func _fixed_process(delta):
	# animation of legs
	if anim_legs_nxt != anim_legs_cur:
		anim_legs_cur = anim_legs_nxt
		_set_legs_animation( anim_legs_cur )
	# animation of body
	_body_animation_fsm()
	if anim_body_cur != anim_body_nxt:
		anim_body_cur = anim_body_nxt
		_set_body_animation( anim_body_cur )
	
	
	if _starting_animation:
		_starting_animation = false
		_set_fx_animation( ANIMATIONS_FX.ARRIVE )
		_is_starting = true
		starting_timer = 1
	if _is_starting:
		starting_timer -= delta
		if starting_timer <= 0:
			_is_starting = false
		return
	
	
		
	if _in_cutscene: return
	if _is_dead: return
	# player input
	if btn_left.check() == 2:
		vel.x = lerp( vel.x, -MAX_VEL.x, ACCEL.x * delta )
		anim_legs_nxt = ANIMATIONS_LEGS.RUN
	elif btn_right.check() == 2:
		vel.x = lerp( vel.x, MAX_VEL.x, ACCEL.x * delta )
		anim_legs_nxt = ANIMATIONS_LEGS.RUN
	else:
		vel.x = lerp( vel.x, 0, 5 * ACCEL.x * delta )
		anim_legs_nxt = ANIMATIONS_LEGS.IDLE
		if vel.x < 5:
			vel.x = 0
	if btn_up.check() == 2:
		vel.y = lerp( vel.y, -MAX_VEL.y, ACCEL.y * delta )
		anim_legs_nxt = ANIMATIONS_LEGS.RUN
	elif btn_down.check() == 2:
		vel.y = lerp( vel.y, MAX_VEL.y, ACCEL.y * delta )
		anim_legs_nxt = ANIMATIONS_LEGS.RUN
	else:
		vel.y = lerp( vel.y, 0, 5 * ACCEL.y * delta )
		if vel.y < 5:
			vel.y = 0
	if btn_fire.check() == 1:
		if anim_body_state == 1 or anim_body_state == 4:
			anim_body_state += 1 # slicing animations
			# search for neighbours
			for n in neighbours:
				if n.get_ref() != null:
					n.get_ref().kill( self )
					game.pause_game( 0.1 )
	
	# motion
	vel = move_and_slide( vel )
	
	# direction
	if vel.x > 0:
		dir_nxt = 1
	elif vel.x < 0:
		dir_nxt = -1
	if ( not _waiting_for_animation ) and dir_nxt != dir_cur:
		dir_cur = dir_nxt
		rotate.set_scale( Vector2( dir_cur, 1 ) )
	
	



func _body_animation_fsm():
	#print( "body_animation_state ", anim_body_state )
	var state_init = anim_body_state
	if anim_body_state == 0:
		# no weapon
		if anim_legs_cur == ANIMATIONS_LEGS.IDLE:
			anim_body_nxt = ANIMATIONS_BODY.IDLE
		elif anim_legs_cur == ANIMATIONS_LEGS.WALK:
			anim_body_nxt = ANIMATIONS_BODY.WALK
		elif anim_legs_cur == ANIMATIONS_LEGS.RUN:
			anim_body_nxt = ANIMATIONS_BODY.RUN
		# acquire weapon
		if game.player_weapon == game.WEAPONS.SWORD:
			anim_body_state = 1
	elif anim_body_state == 1:
		# sword down walking, idle or running
		if anim_legs_cur == ANIMATIONS_LEGS.IDLE:
			anim_body_nxt = ANIMATIONS_BODY.SWORD_DOWN_IDLE
		else:
			anim_body_nxt = ANIMATIONS_BODY.SWORD_DOWN
		if game.player_weapon == game.WEAPONS.NONE:
			anim_body_state = 0
	elif anim_body_state == 2:
		# start slicing up
		if not _waiting_for_animation:
			anim_body_nxt = ANIMATIONS_BODY.SLICE_UP
			_waiting_for_animation = true
			anim_body_state = 3
	elif anim_body_state == 3:
		# slicing up
		if not _waiting_for_animation:
			anim_body_state = 4
	elif anim_body_state == 4:
		if anim_legs_cur == ANIMATIONS_LEGS.IDLE:
			anim_body_nxt = ANIMATIONS_BODY.SWORD_UP_IDLE
		else:
			anim_body_nxt = ANIMATIONS_BODY.SWORD_UP
		if game.player_weapon == game.WEAPONS.NONE:
			anim_body_state = 0
	elif anim_body_state == 5:
		# start sclicing down
		if not _waiting_for_animation:
			anim_body_nxt = ANIMATIONS_BODY.SLICE_DOWN
			_waiting_for_animation = true
			anim_body_state = 6
	elif anim_body_state == 6:
		# slicing down
		if not _waiting_for_animation:
			anim_body_state = 1
	
	#if state_init != anim_body_state:
	#	print( "animation state transition: ", state_init, " -> ", anim_body_state )




func _set_body_animation( a ):
	var legs_pos = anim_legs.get_current_animation_pos()
	#print( "current legs animation position: ", legs_pos )
	if a == ANIMATIONS_BODY.NONE:
		anim_body.play( "none" )
	elif a == ANIMATIONS_BODY.IDLE:
		anim_body.play( "idle" )
		anim_body.seek( legs_pos, true )
	elif a == ANIMATIONS_BODY.WALK:
		anim_body.play( "walk" )
		anim_body.seek( legs_pos, true )
	elif a == ANIMATIONS_BODY.RUN:
		anim_body.play( "run" )
		anim_body.seek( legs_pos, true )
	elif a == ANIMATIONS_BODY.SWORD_DOWN:
		anim_body.play( "sword_down" )
		anim_body.seek( legs_pos, true )
	elif a == ANIMATIONS_BODY.SWORD_DOWN_IDLE:
		anim_body.play( "sword_down_idle" )
		anim_body.seek( legs_pos, true )
	elif a == ANIMATIONS_BODY.SWORD_UP:
		anim_body.play( "sword_up" )
		anim_body.seek( legs_pos, true )
	elif a == ANIMATIONS_BODY.SWORD_UP_IDLE:
		anim_body.play( "sword_up_idle" )
		anim_body.seek( legs_pos, true )
	elif a == ANIMATIONS_BODY.SLICE_DOWN:
		anim_body.play( "slice_down" )
	elif a == ANIMATIONS_BODY.SLICE_UP:
		anim_body.play( "slice_up" )
	

func _set_legs_animation( a ):
	if a == ANIMATIONS_LEGS.IDLE:
		anim_legs.play( "idle" )
	elif a == ANIMATIONS_LEGS.WALK:
		anim_legs.play( "walk" )
	elif a == ANIMATIONS_LEGS.RUN:
		anim_legs.play( "run" )
	var legs_pos = anim_legs.get_current_animation_pos()
	anim_body.seek( legs_pos, true )

enum ANIMATIONS_FX { ARRIVE, LEAVE }
func _set_fx_animation( a ):
	if a == ANIMATIONS_FX.ARRIVE:
		#print( "arrival animation" )
		anim_legs.stop()
		anim_body.stop()
		get_node( "anim_fx" ).play( "arrive" )
	elif a == ANIMATIONS_FX.LEAVE:
		#print( "leave animation" )
		anim_legs.stop()
		anim_body.stop()
		get_node( "anim_fx" ).play( "leave" )


func _set_rotate( a ):
	rotate.set_scale( Vector2( a, 1 ) )
func _set_rotate_head( a ):
	rotate_head.set_scale( Vector2( a, 1 ) )


func _running_dust():
	if vel.x == 0: return
	var dust = preload( "res://scenes/running_dust.tscn" ).instance()
	dust.set_pos( get_pos() + dir_cur * Vector2( 5, 0 ) )
	dust.set_scale( Vector2( dir_cur, 1 ) )
	get_parent().add_child( dust )


func _on_body_animation_finished():
	_waiting_for_animation = false

var _is_dead = false
func kill( source ):
	#print( "checking dead player: ", _is_dead )
	if _is_dead: return false
	_is_dead = true
	self.hide()
	source.connect( "finished_kill", self, "_on_finished_kill" )
	return true

func _on_finished_kill():
	queue_free()
	emit_signal( "is_dead" )


var neighbours = []
func _on_hitbox_area_enter( area ):
	if area.is_in_group( "damagebox" ):
		var obj = area.get_parent()
		if game.findweak( obj, neighbours ) == -1:
			neighbours.append( weakref( area.get_parent() ) )
			#print( "enter: ", neighbours )



func _on_hitbox_area_exit( area ):
	if area.is_in_group( "damagebox" ):
		var obj = area.get_parent()
		var pos = game.findweak( obj, neighbours )
		if pos != -1:
			neighbours.remove( pos )
			#print( "leave: ", neighbours )


