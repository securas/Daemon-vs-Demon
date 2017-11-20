var target_path = []
var target_pos = Vector2()
var navigator = null
var interval = 0
var timer = 0
var optimize = true
var mindist = 9

func _init( interv = 0, nav = null ):
	interval = interv
	if nav != null:
		navigator = nav
	

func get_path_towards( startpos, endpos, delta ):
	if navigator == null:
		# always update
		return endpos
	else:
		timer -= delta
		if timer <= 0:
			timer = interval
			# update path
			var aux = navigator.get_simple_path( startpos, endpos, optimize )
			#print( startpos, " -> ", endpos, "  ", aux )
			# check if this is a valid path
			if ( aux[-1] - endpos ).length_squared() < 10:
				target_path = []
				for a in aux: target_path.append( a )
				target_path.pop_front()
			else: return null
		else:
			# check if reached point
			if not target_path.empty() and ( startpos - target_path[0] ).length_squared() < mindist:
				target_path.pop_front()
			if target_path.empty(): return null
	return target_path[0]



