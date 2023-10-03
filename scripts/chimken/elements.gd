class_name Elements extends Resource


enum Type {
	None		= 0b0000_0000,
	Fire		= 0b0000_0001,
	Water		= 0b0000_0010,
	Electric	= 0b0000_0100,
	Earth		= 0b0000_1000,
	Wind		= 0b0001_0000,
	Light		= 0b0010_0000,
	Dark		= 0b0100_0000,
	Void		= 0b1000_0000
}


static func power_of_2_bit_position(type : Type) -> int:
	if(type < 0 || !Util.is_power_of_2(type)): return -1
	var pos = 0
	while type > 0:
		pos += 1
		type >>= 1
	return pos
