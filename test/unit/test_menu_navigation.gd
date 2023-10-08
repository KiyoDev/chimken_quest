extends GutTest


func test_navigate_grid_menu():
	var grid_menu := GridMenu.new();
	# [4][6]
	# 0  1  2  3  4  5
	# 6  7  8  9  10 11
	# 12 13 14 15 16 17
	# 18 19 20 21 22 23
	var rows := 4;
	var columns := 6;
	var area := rows * columns;
	grid_menu.rows = rows;
	grid_menu.columns = columns;
	# curr=5, columns=6, base=0, size=24, last=base+6
	# v = curr + columns - 1 % size;
	# v + (base * (v + 1) % size);
	# (5 + 6 - 1) % 24 + (0 * (v + 1) % 24; 10 % 24 + (0 * (10 + 1) % 24)
	#
	# v = curr + columns - 1 % last;
	# v + (base * (v + 1) % last);
	# 5 + 6 - 1 % 6 = 10 % 6 = 4; 4 + (0 * (4 + 1) % 6)
	#
	# 17 + 6 - 1 % 18 = 23 % 18 = 5; 5 + (12 * (5 + 1) % 18); 5 + (12 * 6) % 18 = 5 + (72 % 18)
	
	
	# 10 % 24 = 10
	# 10 + (0 * (0 + 1) % 24) = 0 + (18 % 24) = 18
	
	# Wrap Tests
	grid_menu.wrap = true;
	# Up
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(0, -1));
			if(n == 0):
				assert_eq(grid_menu.focused_index, m + ((rows - 1) * columns));
			else:
				assert_eq(grid_menu.focused_index, start - columns);
	# Down
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(0, 1));
			if(n == rows - 1):
				assert_eq(grid_menu.focused_index, m);
			else:
				assert_eq(grid_menu.focused_index, start + columns);
	# Left
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(-1, 0));
			if(m == 0):
				assert_eq(grid_menu.focused_index, n * columns + columns - 1);
			else:
				assert_eq(grid_menu.focused_index, start - 1);
	# Right
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(1, 0));
			if(m == columns - 1):
				assert_eq(grid_menu.focused_index, n * columns);
			else:
				assert_eq(grid_menu.focused_index, start + 1);
 
	# No Wrap Tests
	grid_menu.wrap = false;
	# Up
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(0, -1));
			if(n == 0):
				assert_eq(grid_menu.focused_index, start);
			else:
				assert_eq(grid_menu.focused_index, start - columns);
	# Down
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(0, 1));
			if(n == rows - 1):
				assert_eq(grid_menu.focused_index, start);
			else:
				assert_eq(grid_menu.focused_index, start + columns);
	# Left
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(-1, 0));
			if(m == 0):
				assert_eq(grid_menu.focused_index, start);
			else:
				assert_eq(grid_menu.focused_index, start - 1);
	
	# Right
	for n in rows:
		for m in columns:
			var start := n * columns + m;
			grid_menu.focused_index = start;
			grid_menu._navigate(Vector2(1, 0));
			if(m == columns - 1):
				assert_eq(grid_menu.focused_index, start);
			else:
				assert_eq(grid_menu.focused_index, start + 1);
