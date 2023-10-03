class_name Condition extends Resource


enum Op {
	EQUAL,
	NOT_EQUAL,
	GREAT_THAN,
	LESS_THAN,
	GREAT_THAN_OR_EQUAL_TO,
	LESS_THAN_OR_EQUAL_TO
}

@export var op := Op.EQUAL;


func resolve(params : Dictionary):
	pass;


func get_value():
	pass;


func compare(val) -> bool:
	var res := false;
	if op == Op.EQUAL:
		res = get_value() == val;
	elif op == Op.NOT_EQUAL:
		res = get_value() != val;
	elif op == Op.GREAT_THAN:
		res = get_value() > val;
	elif op == Op.LESS_THAN:
		res = get_value() < val;
	elif op == Op.LESS_THAN_OR_EQUAL_TO:
		res = get_value() <= val;
	elif op == Op.GREAT_THAN_OR_EQUAL_TO:
		res = get_value() >= val;
	return res


func _to_string():
	var val = get_value();
	return "{\"value\":%s,\"op\":%s}" % [("\"%s\"" % val) if val is String else val, op];
