class_name DialogueFile extends RefCounted


var name := "";

var connections : Array[Dictionary] = [];

# Keep node info as dictionary to be parsed into DialogueNodes
var nodes : Array[Dictionary] = [];


#static var json := JSON.new();


func from_json(json):
	var Json = JSON.new();
	var error = Json.parse(json);
	if(error):
		push_error("Unable to parse json text");
		return;
	
	var data = Json.data;
	if(typeof(data) != TYPE_DICTIONARY):
		push_error("Incoming file must be a dictionary, was '%s'" % [typeof(data)]);
		return;
	
#	print_debug("dialogue(%s)" % JSON.stringify(data));
	print_debug("dialogue(%s)" % data);
#	JSON.parse(json);
	pass;
