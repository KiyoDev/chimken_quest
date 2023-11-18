@tool
extends Node

static var nested := Nested1.new()


func currency():
	return 2147483547


func multi_params(int_value, float_value, bool_value, string_value, variable):
	
	return 1240;


class Nested1 extends Node:
	static var nested := Nested2.new()

class Nested2 extends Node:
	
	var value := -2147483548
	
