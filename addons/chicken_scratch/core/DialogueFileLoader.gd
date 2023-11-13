#@tool
#class_name DialogueFileLoader extends RefCounted
#
#
#func open_json_from_path(path : String) -> Dictionary:
##	print_debug("opening file '%s'" % [path])
#	var file := FileAccess.open(path, FileAccess.READ)
#	var dict = from_json(file.get_as_text())
#	print_debug("dialogue(%s)" % JSON.stringify(dict, "\t", false))
#
#	if(!dict.has("connections") || !dict.has("root_node") || !dict.has("root_node") || !dict.has("nodes") || !(dict.connections is Array) || !(dict.nodes is Dictionary) || !dict.has("variables")): 
#		push_error("Unable to load file. Invalid formatting.")
#		return {}
#
#	return dict
##	connections = dict.connections
###	variables = dict.variables
##	root_node = dict.root_node
##	nodes = dict.nodes
#
#
#func from_json(text : String):
#	var json = JSON.new()
#	var error = json.parse(text)
#	if(error):
#		push_error("Unable to parse json text")
#		return {}
#
#	var data = json.data
#	if(typeof(data) != TYPE_DICTIONARY):
#		push_error("Incoming file must be a dictionary, was '%s'" % [typeof(data)])
#		return {}
#
##	print_debug("dialogue(%s)" % JSON.stringify(data, "\t", false))
#	return data as Dictionary
