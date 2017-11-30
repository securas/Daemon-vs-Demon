extends Sprite
# Generic params
enum ANIMS { NONE, IDLE, RUN, ATTACK, PICK, ARRIVE, LEAVE }

onready var anim_legs = get_node( "anim_legs" )
onready var anim_body = get_node( "anim_body" )
onready var anim_fx = get_node( "anim_fx" )
var cur_anim = -1
var nxt_anim = -1#ANIMS.NONE
var running_legs = false
var running_body = false
var running_fx = false
var cur_pos = " d"

var _is_ready = false

func play_event(event):
	SoundManager.Play(event)


func _ready():
	#if not _is_ready:
	#	_is_ready = true
	#	return
	set_fixed_process( true )

func _fixed_process(delta):
	#print( "nxt anim: ", nxt_anim, "   cur anim ", cur_anim, "   finished ", anim_finished() )
	if nxt_anim != cur_anim and anim_finished():
		#print( "playing animation ", nxt_anim )
		cur_anim = nxt_anim
		_set_animation( cur_anim )

func set_animation( a ):
	nxt_anim = a

func _set_animation( a ):
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

func anim_finished():
	if cur_anim == ANIMS.NONE:
		return true
	elif cur_anim == ANIMS.IDLE:
		return true
	elif cur_anim == ANIMS.RUN:
		return true
	elif cur_anim == ANIMS.ATTACK:
		return not running_body
	elif cur_anim == ANIMS.PICK:
		if ( not running_body ) and ( not running_legs ):
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
	if anim_legs.get_current_animation() != "idle":
		anim_legs.play( "idle" )
	running_legs = true
	# body
	if not anim_body.get_current_animation().begins_with( "none" ):
		anim_body.play( "none" + cur_pos )
	running_body = true

func _set_idle():
	# legs
	if anim_legs.get_current_animation() != "idle":
		anim_legs.play( "idle" )
	running_legs = true
	# body
	if not anim_body.get_current_animation().begins_with( "idle" ):
		anim_body.play( "idle" + cur_pos )
	running_body = true

func _set_run():
	# legs
	if anim_legs.get_current_animation() != "run":
		anim_legs.play( "run" )
	running_legs = true
	# body
	if anim_body.get_current_animation().begins_with( "attack" ):
		# it might still be attacking
		if not running_body:
			# it's finished, play run animation
			anim_body.play( "run" + cur_pos )
			anim_body.seek( anim_legs.get_current_animation_pos() )
			running_body = true
	elif not anim_body.get_current_animation().begins_with( "run" ):
		anim_body.play( "run" + cur_pos )
		# synchronize
		anim_body.seek( anim_legs.get_current_animation_pos() )
		running_body = true

func _set_attack():
	# body
	if not anim_body.get_current_animation().begins_with( "attack" ):
		anim_body.play( "attack" + cur_pos )
		if cur_pos == " u": cur_pos = " d"
		else: cur_pos = " u"
	running_body = true
	pass

func _set_pick():
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
	_set_none()
	anim_body.stop()
	anim_legs.stop()
	running_legs = false
	running_body = false
	# run arrive animation
	anim_fx.play( "arrive" )
	running_fx = true

func _set_leave():
	# stop all other animations
	_set_none()
	anim_body.stop()
	anim_legs.stop()
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



func _running_dust():
	if game.player!= null and game.player.get_ref() != null:
		var player = game.player.get_ref()
		if player.vel.x == 0:
			player = null
			return
		var dir_cur = get_parent().get_scale().x
		#print( "dir cur ", dir_cur )
		var dust = preload( "res://scenes/running_dust.tscn" ).instance()
		dust.set_pos( player.get_pos() + dir_cur * Vector2( 5, 0 ) )
		dust.set_scale( Vector2( dir_cur, 1 ) )
		#print( get_parent().get_parent().get_parent().get_name() )
		player.get_parent().add_child( dust )
		player = null

