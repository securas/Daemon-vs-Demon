extends Node2D

var drop_texture = preload( "res://assets/blood.png" )

const COLORS = [ \
	Color( 108 / 255.0, 12 / 255.0, 48 / 255.0 ), \
	Color( 128 / 255.0, 20 / 255.0, 56 / 255.0 ), \
	Color( 148 / 255.0, 08 / 255.0, 52 / 255.0 ) ]

class Drop:
	var pos = Vector2()
	var vel = Vector2()
	var hvel = 0
	var draw_pos = Vector2()
	var height = 0
	var state = 0
	var color = Color( 1, 0, 0 )
	var size = 1
	var frame = 0
var drops = []

var rects = []
const W = 6
func _ready():
	#create_blood( Vector2( 100, 100 ), 50, Vector2( 40, 0 ), 10, 1, 10000 )
	rects = []
	for x in range( 2 ):
		for y in range( 2 ):
			rects.append( Rect2( Vector2( x * W, y * W ), Vector2( W, W ) ) )
	set_fixed_process( true )

func create_blood( pos, extent, height, extent_height, vel, vel_range, number ):
	for n in range( number ):
		var d = Drop.new()
		d.vel = rand_range( 0.5, 1 ) * vel.rotated( rand_range( -vel_range, vel_range ) * ( 2 * PI ) / 360.0 )
		d.pos = pos + Vector2( extent.x * rand_range( -1, 1 ), extent.y * rand_range( -1, 1 ) )
		d.height = height + rand_range( -1, 1 ) * extent_height
		d.hvel = 30#rand_range( -10, 50 )
		var cpos = randi() % COLORS.size()
		d.color = COLORS[cpos]
		d.frame = ( randi() % 4 )
		drops.append( d )


const GRAVITY = 100

var t = 2
func _fixed_process(delta):
	var _update_draw = false
	var gpos = get_global_pos()
	var toremove = []
	var aux = GRAVITY * delta
	for idx in range( drops.size() ):
		if drops[idx].state == 0:
			#drops[idx].hvel += aux
			drops[idx].height -= drops[idx].hvel * delta
			drops[idx].pos += drops[idx].vel * delta
			drops[idx].vel *= 0.9
			drops[idx].draw_pos = drops[idx].pos - gpos
			drops[idx].draw_pos.y -= drops[idx].height
			drops[idx].draw_pos = Vector2( int( drops[idx].draw_pos.x ), int( drops[idx].draw_pos.y ) )
			_update_draw = true
			if drops[idx].height <= 0:
				drops[idx].state = 1
	if _update_draw:
		update()
		SoundManager.Play("en_gore")
		
	t -= delta
	if t <= 0:
		#print( drops.size() )
		t = 2





func _draw():
	for d in drops:
		#draw_texture( drop_texture, d.draw_pos, d.color )
		#draw_texture_rect( drop_texture, Rect2( d.draw_pos, Vector2( d.size, d.size ) ), \
		#		true, d.color )
		draw_texture_rect_region( drop_texture, Rect2( d.draw_pos, Vector2( W, W ) ), \
				rects[d.frame], d.color )