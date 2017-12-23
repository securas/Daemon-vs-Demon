extends Node2D
export( NodePath ) var RainParent = null
export( NodePath ) var GroundNode = null

var num_drops = 600#1200
var extent = Vector2( 240, 135 )
var parent_node#= "../"
var ground_node
var rain_drop_scn = preload( "res://scenes/rain_drop.tscn" )
var drops = []
class Drop:
	var instance = null
	var frame = 0
	#var timer = 0
	var has_parent = false
	var update_rate = 0.05
	var frame_speed = 1
	var float_frame = 0
	var final_frame = 27
	var active = true
	func update():
		#var out = false
		float_frame += 0.1
		frame = int( float_frame / update_rate )
		if frame >= final_frame:
			frame = 0
			float_frame = 0
			#out = true
		#frame = ( frame + 1 ) % final_frame
		instance.set_frame( frame )
		return ( frame == 0 )
	func clear():
		instance.queue_free()


var _stop_rain = false
func stop():
	if not _stop_rain:
		_stop_rain = true
	pass

func _ready():
	#return
	randomize()
	parent_node = get_node( RainParent )
	ground_node = get_node( GroundNode )
	print( "rain parent: ", parent_node.get_name() )
	# create drop instances
	for n in range( num_drops ):
		var d = Drop.new()
		d.instance = rain_drop_scn.instance()
		d.frame = int( rand_range( 0, 27 ) )
		d.instance.set_frame( d.frame )
		drops.append( d )
	set_fixed_process( true )

var gpos = Vector2()
var timer = 0.0
func _fixed_process( delta ):
	timer -= delta
	if timer <= 0:
		timer = 0.1
		gpos = get_global_pos()
		var active_drops = false
		for d in drops:
			if not d.active: continue
			if not d.has_parent:
				parent_node.add_child( d.instance )
				d.has_parent = true
				_set_random_pos( d )
			if not _stop_rain:
				if d.update():
					_set_random_pos( d )
			else:
				#print( "stopping ", d, " :", d.frame )
				if d.update():
					#print( "stopped ", d )
					d.active = false
					d.instance.queue_free()
			active_drops = true
		if not active_drops: set_fixed_process( false )
	
	
	
#	for d in drops:
#		if not d.active: continue
#		if not d.has_parent:
#			parent_node.add_child( d.instance )
#			d.has_parent = true
#			_set_random_pos( d )
#		if not _stop_rain:
#			if d.update( delta ):
#				_set_random_pos( d )
#		else:
#			if d.update( delta ):
#				d.active = false
#				d.instance.queue_free()
	
	# follow target
	if game.player != null and game.player.get_ref() != null:
		set_global_pos( game.player.get_ref().get_global_pos() + Vector2( 0, 50 ) )

func _set_random_pos( d ):
	var offset = Vector2( round( rand_range( -extent.x, extent.x ) ), round( rand_range( -extent.y, extent.y ) ) )
	d.final_frame = 27
	d.instance.set_global_pos( gpos + offset )
	d.instance.set_modulate( Color( 1, 1, 1, rand_range( 0.05, 0.4 ) ) )
	d.update_rate = rand_range( 0.02, 0.1 )
	#print( offset )
	#print( "updating position: ", d.instance.get_global_pos() )
	if _check_ground( gpos + offset + Vector2( 0, -3 ) ):
		d.final_frame = 27
	else:
		d.final_frame = 22

	

func _check_ground( gpos ):
	var tilepos = ground_node.world_to_map( gpos )
	if ground_node.get_cell( tilepos.x, tilepos.y ) == -1:
		return false
	return true








