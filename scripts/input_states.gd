### class for input handling. Returns 4 button states
#by: Andreas Esau

var input_name
var prev_state
var cur_state
var input

var out_state
var state_old

### Get the input name and store it
func _init(var input_name):
	self.input_name = input_name
	
### Check the input and compare ir with previous states
func check():
	input = Input.is_action_pressed(self.input_name)
	prev_state = cur_state
	cur_state = input
	
	state_old = out_state
	
	if not prev_state and not cur_state:
		out_state = 0 ### released
	if not prev_state and cur_state:
		out_state = 1 ### just pressed
	if prev_state and cur_state:
		out_state = 2 ### pressed
	if prev_state and not cur_state:
		out_state = 3 ### just released
	
	return out_state