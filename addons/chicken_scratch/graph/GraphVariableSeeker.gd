@tool
class_name GraphVariableSeeker extends Node


signal variables_requested(vars : Array);

signal got_variables(variables : Dictionary);


var variables := {};
var variables_set := false;


func _ready():
	pass;


func set_variables(vars : Dictionary):
	var variables := {};
	for key in vars:
		variables[key] = vars[key];
	
	print_debug("setting variables - %s" % [variables]);
#	variables_set = true;
	got_variables.emit(variables);



func seek(vars : Array) -> Dictionary:
	variables_requested.emit(vars);
	
#	await variables_set;
#	variables_set = false;
	var results = await got_variables;
	print_debug("got variables - %s" % [results]);
	
	return results;
