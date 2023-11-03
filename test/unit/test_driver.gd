extends GutTest


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 
# row # * columns = base of row; 0 * 4 = 0, 1 * 4 = 4
# 0  1  2  3  4  5
# 6  7  8  9  10 11
# 12 13 14 15 16 17
# curr / columns = row#
# curr + 1 % (columns) + ((curr / columns) * columns)
func test_main():
	print_debug("11/6=%s" % [11 / 6]);
	var rows := 3;
	var columns := 6;
	var curr = 17;
	
	print_debug("before:%s" % [curr]);
	curr = (curr + 1) % columns + ((curr / columns) * columns);
	print_debug("curr -> :%s" % [curr]);
