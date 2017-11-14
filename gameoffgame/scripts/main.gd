extends Node2D

var act_cur = ""
var act_nxt = "res://scenes/act_1/act_1.tscn"
var state = -10
var state_nxt = -10
var timer = 0
func _ready():
	set_fixed_process( true )


func _fixed_process( delta ):
	if act_nxt != act_cur:
		act_cur = act_nxt
		state = 0
	load_act( delta )



func load_act( delta ):
	if state == -1:
		timer -= delta
		if timer <= 0:
			state = state_nxt
	elif state == 0:
		# fade out
		state = -1
		timer = 0.25
		state_nxt = 1
	elif state == 1:
		# clear current act
		var children = get_node( "act" ).get_children()
		for c in children:
			c.queue_free()
		state = -1
		timer = 0.25
		state_nxt = 2
	elif state == 2:
		# load new act
		var act_scn = load( act_nxt )
		var act = act_scn.instance()
		get_node( "act" ).add_child( act )
		state = -1
		timer = 0.25
		state_nxt = 3
	elif state == 3:
		# fade in
		state = -1
		timer = 0.25
		state_nxt = 4





