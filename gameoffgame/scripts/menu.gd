extends Node2D

signal selected_item
var input_states = preload( "res://scripts/input_states.gd" )
var btn_up = input_states.new( "btn_up" )
var btn_down = input_states.new( "btn_down" )
var btn_fire = input_states.new( "btn_fire" )


var cur_pos = 0
var nxt_pos = 0
var max_pos = 0
var items = []
func _ready():
	items = get_children()
	for idx in range( 1, items.size() ):
		items[idx].set_opacity( 0.3 )
	max_pos = items.size() - 1
	pass

func set_active( v ):
	if v: set_fixed_process( true )
	else: set_fixed_process( false )


func _fixed_process(delta):
	if btn_fire.check() == 1:
		emit_signal( "selected_item", cur_pos )
	if btn_down.check() == 1:
		nxt_pos += 1
	elif btn_up.check() == 1:
		nxt_pos -= 1
	if nxt_pos < 0: nxt_pos = 0
	elif nxt_pos > max_pos: nxt_pos = max_pos
	
	if nxt_pos != cur_pos:
		cur_pos = nxt_pos
		_update_pos( cur_pos )

func _update_pos( pos ):
	for idx in range( items.size() ):
		if idx == pos:
			items[idx].set_opacity( 1 )
		else:
			items[idx].set_opacity( 0.3 )

