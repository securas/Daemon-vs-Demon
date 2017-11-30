extends Sprite
# Generic params
enum ANIMS { NONE, IDLE, RUN, ATTACK, PICK, ARRIVE, LEAVE }
 
#onready var anim_legs = get_node( "anim_legs" )
onready var anim_body = get_node( "anim_body" )
onready var anim_fx = get_node( "anim_fx" )
var cur_anim = -1
var nxt_anim = ANIMS.NONE
var running_legs = false
var running_body = false
var running_fx = false
var cur_looking_dir = 1

func play_event(event):
	SoundManager.Play(event)

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
		if running_body: return false
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
	return

func look_forward():
	return



func _set_none():
	# body
	if anim_body.get_current_animation() != "idle":
		anim_body.play( "idle" )
	running_body = true

func _set_idle():
	# body
	if anim_body.get_current_animation() != "idle":
		anim_body.play( "idle" )
	running_body = true

func _set_run():
	# body
	if anim_body.get_current_animation() != "run":
		anim_body.play( "run" )
	running_body = true

func _set_attack():
	if game.player != null and game.player.get_ref() != null and not game.player.get_ref().is_dead():
		game.player.get_ref().vel *= 0
	
	if anim_body.get_current_animation() != "fire":
		anim_body.play( "fire" )
	running_body = true
	return

func _set_pick():
	return

func _set_arrive():
	# stop all other animations
	anim_body.stop()
	running_legs = false
	running_body = false
	# run arrive animation
	anim_fx.play( "arrive" )
	running_fx = true

func _set_leave():
	# stop all other animations
	anim_body.stop()
	running_legs = false
	running_body = false
	# run leave animation
	anim_fx.play( "leave" )
	running_fx = true


func _on_anim_body_finished():
	running_body = false

func _on_anim_fx_finished():
	running_fx = false


func _on_fire_bullet():
	if game.player == null or game.player.get_ref() == null or game.player.get_ref().is_dead():
		return
	# stop plyaer
	game.player.get_ref().vel *= 0
	# shooting direction
	var shooting_dir = Vector2( game.player.get_ref().dir_cur, 0 )
	# external impulse
	#external_impulse = -shooting_dir * 10000
	#external_impulse_timer = 0.05
	
	# instance bullet
	var bullet = preload( "res://scenes/monster_bullet.tscn" ).instance()
	bullet.set_pos( game.player.get_ref().get_pos() + 15 * shooting_dir )
	bullet.dir = shooting_dir.normalized()
	SoundManager.Play("en_orb_atk")
	# change bullet masks to kill monsters
	bullet.set_layer_mask_bit( 1, true )
	bullet.set_collision_mask_bit( 1, true )
	bullet.set_layer_mask_bit( 0, false )
	bullet.set_collision_mask_bit( 0, false )
	bullet.set_player( true )
	game.player.get_ref().get_parent().add_child( bullet )



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