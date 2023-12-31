class_name Util extends RefCounted


static func count_bits(n : int) -> int:
	var count = 0
	while n:
		count += n & 1
		n >>= 1
	return count


static func power_of_2_bit_position(n : int) -> int:
	if(n < 0): return -1
	var pos = 0
	while n > 0:
		pos += 1
		n >>= 1
	return pos
	

static func is_power_of_2(n : int) -> bool:
	if(n < 0): return false
	return (n & n - 1) == 0
	

static func pixel_clamp(move : Vector2) -> Vector2:
	var pixel = Vector2(roundi(move.x * 16), roundi(move.y * 16));
#	print_debug("px-%s, %s" % [pixel, pixel / 16]);
	
	return pixel / 16;

