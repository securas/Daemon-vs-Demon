extends Sprite
# Generic params
enum ANIMS { NONE, IDLE, RUN, ATTACK, PICK, ARRIVE, LEAVE }

onready var anim_legs = get_node( "anim_legs" )
onready var anim_body = get_node( "anim_body" )
onready var anim_fx = get_node( "anim_fx" )
var cur_anim = -1
var nxt_anim = ANIMS.NONE
var running_legs = false
var running_body = false
var running_fx = false
var cur_looking_dir = 1

var _is_ready = false
func _ready():
	if not _is_ready:
		_is_ready = true
		return
	set_fixed_process( true )

func _fixed_process(delta):
	if nxt_anim != cur_anim:
		set_animation( nxt_anim )
	

func set_animation( a ):
	if not anim_finished():
		nxt_anim = a
		return
	if a == ANIMS.NONE:
		_set_none()
	elif a == ANIMS.IDLE:
		_set_idle()
	elif a == ANIMS.RUN:
		_set_run()
	elif a == ANIMS.ATTACK:
		_set_attack()
	elif a == ANIMS.PICK:
		_set_pick()
	elif a == ANIMS.ARRIVE:
		_set_arrive()
	elif a == ANIMS.LEAVE:
		_set_leave()
	cur_anim = a

func anim_finished():
	if cur_anim == ANIMS.NONE:
		return true
	elif cur_anim == ANIMS.IDLE:
		return true
	elif cur_anim == ANIMS.RUN:
		return true
	elif cur_anim == ANIMS.ATTACK:
		return true
	elif cur_anim == ANIMS.PICK:
		return true
	elif cur_anim == ANIMS.ARRIVE:
		if not running_fx: return true
	elif cur_anim == ANIMS.LEAVE:
		if not running_fx: return true
	elif cur_anim == -1:
		return true
	return false

func look_behind():
	get_node( "body/rotate_head" ).set_scale( Vector2( -1, 1 ) )

func look_forward():
	get_node( "body/rotate_head" ).set_scale( Vector2( 1, 1 ) )



func _set_none():
	# legs
	if anim_legs.get_current_animation() != "cycle":
		anim_legs.play( "cycle" )
	running_legs = true
	# body
	if anim_body.get_current_animation() != "cycle":
		anim_body.play( "cycle" )
	running_body = true

func _set_idle():
	# legs
	if anim_legs.get_current_animation() != "cycle":
		anim_legs.play( "cycle" )
	running_legs = true
	# body
	if anim_body.get_current_animation() != "cycle":
		anim_body.play( "cycle" )
	running_body = true

func _set_run():
	# legs
	if anim_legs.get_current_animation() != "cycle":
		anim_legs.play( "cycle" )
	running_legs = true
	# body
	if anim_body.get_current_animation() != "cycle":
		anim_body.play( "cycle" )
		# synchronize
		anim_body.seek( anim_legs.get_current_animation_pos() )
	running_body = true

func _set_attack():
	_set_pick()
	pass

func _set_pick():
	return
	# legs
	if anim_legs.get_current_animation() != "pick":
		anim_legs.play( "pick" )
	running_legs = true
	# body
	if anim_body.get_current_animation() != "pick":
		anim_body.play( "pick" )
		# synchronize
		anim_body.seek( anim_legs.get_current_animation_pos() )
	running_body = true

func _set_arrive():
	# stop all other animations
	anim_legs.stop()
	anim_body.stop()
	running_legs = false
	running_body = false
	# run arrive animation
	anim_fx.play( "arrive" )
	running_fx = true

func _set_leave():
	# stop all other animations
	anim_legs.stop()
	anim_body.stop()
	running_legs = false
	running_body = false
	# run leave animation
	anim_fx.play( "leave" )
	running_fx = true


func _on_anim_body_finished():
	running_body = false

func _on_anim_legs_finished():
	running_legs = false

func _on_anim_fx_finished():
	running_fx = false


