extends Node2D

var num_drops = 1200
var extent = Vector2( 240, 135 )
var parent_node = "../"
var rain_drop_scn = preload( "res://scenes/rain_drop.tscn" )
var drops = []
class Drop:
	var instance = null
	var frame = 0
	var timer = 0
	var has_parent = false
	var update_rate = 0.05
	func update( delta ):
		timer -= delta
		var output = false
		if timer <= 0:
			if frame < 23:
				timer = update_rate
			else:
				timer = 0.15
			frame = ( frame + 1 ) % 27
		if frame != instance.get_frame():
			instance.set_frame( frame )
			if frame == 0:
				return true
		return false

func _ready():
	randomize()
	print( "rain parent: ", get_node( parent_node ).get_name() )
	# create drop instances
	for n in range( num_drops ):
		var d = Drop.new()
		d.instance = rain_drop_scn.instance()
		d.frame = int( rand_range( 0, 27 ) )
		d.instance.set_frame( d.frame )
		drops.append( d )
	set_fixed_process( true )

var gpos = Vector2()
func _fixed_process( delta ):
	#print( gpos, " ", drops[0].instance.get_global_pos(), " ", drops[0].frame )
	gpos = get_global_pos()
	for d in drops:
		if not d.has_parent:
			get_node( parent_node ).add_child( d.instance )
			d.has_parent = true
			_set_random_pos( d )
		if d.update( delta ):
			_set_random_pos( d )
	# follow target
	if game.player != null and game.player.get_ref() != null:
		set_global_pos( game.player.get_ref().get_global_pos() + Vector2( 0, 50 ) )

func _set_random_pos( d ):
	var offset = Vector2( round( rand_range( -extent.x, extent.x ) ), round( rand_range( -extent.y, extent.y ) ) )
	d.instance.set_global_pos( gpos + offset )
	d.instance.set_modulate( Color( 1, 1, 1, rand_range( 0.05, 0.4 ) ) )
	d.update_rate = rand_range( 0.02, 0.1 )
	#print( offset )
	#print( "updating position: ", d.instance.get_global_pos() )









