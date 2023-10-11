@tool
class_name GridMenu extends MenuBase


# [3][4]
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 
# row # * columns = base of row; 0 * 4 = 0, 1 * 4 = 4
# [4][6]
# 0  1  2  3  4  5
# 6  7  8  9  10 11
# 12 13 14 15 16 17
# 18 19 20 21 22 23
# curr / columns = row# or curr % columns
# curr + 1 % (columns) + ((curr / columns) * columns)

# curr - 1 + (curr/columns) * columns
# COULD make actual 2D array, if menu children are just row containers that contain column children
@export var rows := 2;
@export var columns := 2;
@export var wrap := false;


var focused_index := 0;


func _navigate(direction):
	nav_helper(direction);


func nav_helper(direction):
	if(!is_focused || get_child_count() == 0): return get_child(focused_index);
	
	if(wrap):
		var size = (rows * columns);
		if(direction.x > 0): # right
			focused_index = (focused_index + 1) % columns + ((focused_index / columns) * columns);
		elif(direction.x < 0): # left
			focused_index = focused_index + columns - 1 if (focused_index % columns == 0) else focused_index - 1;
		elif(direction.y > 0): # down
			# (focused_index + colums) % (size)
			focused_index = (focused_index + columns) % size;
		elif(direction.y < 0): # up
			# (focused_index - columns + (size)) % (size)
			focused_index = (focused_index - columns + size) % size;
		return get_child(focused_index);
	else:
		if(direction.x > 0): # right
			focused_index = min((focused_index / columns + 1) * columns - 1, focused_index + 1);
		elif(direction.x < 0): # left
			focused_index = max((focused_index / columns) * columns, focused_index - 1);
		elif(direction.y > 0): # down
			# curr - ((curr / columns) * columns) = column index
			# (r * c) - c = last row
			focused_index = min((focused_index - (focused_index / columns) * columns) + ((rows * columns) - columns), focused_index + columns);
			pass;
		elif(direction.y < 0): # up
			# (curr - colums + (r*c)) % (r*c)
			focused_index = max((focused_index - (focused_index / columns) * columns), focused_index - columns);
		return get_child(focused_index);


func _select_option():
	return get_child(focused_index);
