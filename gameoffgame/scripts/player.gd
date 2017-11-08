extends KinematicBody2D

var input_states = preload( "res://scripts/input_states.gd" )
var btn_left = input_states.new( "btn_left" )
var btn_right = input_states.new( "btn_right" )
var btn_up = input_states.new( "btn_up" )
var btn_down = input_states.new( "btn_down" )
#var btn_jump = input_states.new( "btn_jump" )
#var btn_fire = input_states.new( "btn_fire" )


const MAX_VEL = Vector2( 80, 50 )
const ACCEL = Vector2( 10, 8 )
var vel = Vector2()

var dir_cur = 0
var dir_nxt = 0
var is_moving_nxt = 0
var is_moving_cur = 0

#onready var anim = get_node( "anim" )
const animations = [ \
		[ "idle_right", "idle_down", "idle_left", "idle_up" ], \
		[ "run_right", "run_down", "run_left", "run_up" ] ]
var anim_cur = ""
var anim_nxt = "run_right"

func _ready():
	get_node( "anim_body" ).play( "run_right" )
	get_node( "anim_legs" ).play( "run_right" )
	set_fixed_process( true )


func _fixed_process(delta):
	# player input
	if btn_left.check() == 2:
		vel.x = lerp( vel.x, -MAX_VEL.x, ACCEL.x * delta )
		is_moving_nxt = 1
	elif btn_right.check() == 2:
		vel.x = lerp( vel.x, MAX_VEL.x, ACCEL.x * delta )
		is_moving_nxt = 1
	else:
		vel.x = lerp( vel.x, 0, 5 * ACCEL.x * delta )
		is_moving_nxt = 0
		if vel.x < 5:
			vel.x = 0
	if btn_up.check() == 2:
		vel.y = lerp( vel.y, -MAX_VEL.y, ACCEL.y * delta )
		is_moving_nxt = 1
	elif btn_down.check() == 2:
		vel.y = lerp( vel.y, MAX_VEL.y, ACCEL.y * delta )
		is_moving_nxt = 1
	else:
		vel.y = lerp( vel.y, 0, 5 * ACCEL.y * delta )
		is_moving_nxt = 0
		if vel.y < 5:
			vel.y = 0
	
	# motion
	vel = move_and_slide( vel )
	
	# direction
	if abs( vel.x ) >= abs( vel.y ):
		if vel.x > 0:
			dir_nxt = 0
			is_moving_nxt = 1
		elif vel.x < 0:
			dir_nxt = 2
			is_moving_nxt = 1
		else:
			is_moving_nxt = 0
	elif abs( vel.x ) < abs( vel.y ):
		if vel.y > 0:
			dir_nxt = 1
			is_moving_nxt = 1
		elif vel.y < 0:
			dir_nxt = 3
			is_moving_nxt = 1
		else:
			is_moving_nxt = 0
	#print( dir_nxt )
	# animation
	if dir_nxt != dir_cur or is_moving_nxt != is_moving_cur:
		dir_cur = dir_nxt
		is_moving_cur = is_moving_nxt
		print( "playing: ", animations[is_moving_cur][dir_cur], "   ", dir_cur, "   ", is_moving_cur )
		#anim.play( animations[is_moving_cur][dir_cur] )
	
