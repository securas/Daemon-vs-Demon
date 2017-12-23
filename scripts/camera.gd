extends Camera2D

var zoom_nxt = 1.0
var ZOOM_SPEED = 1


var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)


func _ready():
	# register
	game.camera = weakref( self )
	# process
	set_fixed_process( true )

func _fixed_process( delta ):
	if game.camera_target == null: return
	var target = game.camera_target.get_ref()
	if target == null: return
	var newpos = target.get_global_pos()
	newpos.x = round( newpos.x )
	newpos.y = round( newpos.y )
	set_global_pos( newpos )
	
	zoom_nxt = lerp( zoom_nxt, game.camera_target_zoom, delta * ZOOM_SPEED )
	if abs( zoom_nxt - game.camera_target_zoom ) < 0.01:
		zoom_nxt = game.camera_target_zoom
	if zoom_nxt != get_zoom().x:
		set_zoom( zoom_nxt * Vector2( 1, 1 ) )
	
	# Only shake when there's shake time remaining.
	if _timer == 0: return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)
		is_shaking = false

var is_shaking = false
# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
	if is_shaking: return
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)

