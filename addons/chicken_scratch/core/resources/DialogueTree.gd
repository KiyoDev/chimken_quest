@tool
class_name DialogueTree extends Resource

#{
#	"connections": Graph.get_connection_list(),
#	"variables": get_graph_variables(),
#	"root_node": root_node.to_dict(),
#	"nodes": get_graph_node_dicts()
#}

@export var path := ""
@export var connections := {}
@export var variables := {}
@export var root_node := {}
@export var nodes := {}


func to_dict() -> Dictionary:
	return {
		"connections": connections,
		"variables": variables,
		"root_node": root_node,
		"nodes": nodes
	}


func connection_dict(connections : Array) -> Dictionary:
	var dict := {}
	for connection in connections:
		if(!dict.has(connection.from)):
#			print_debug("add new connection to dict")
			dict[connection.from] = {}
		# support multiple connections at same "from_port"?
		dict[connection.from][connection.from_port] = {"to": connection.to, "to_port": connection.to_port}

	return dict


func node_is_connected(from : String, from_port : int):
	return connections.has(from) && connections[from].has(from_port)


func connect_node(from : String, from_port : int, to : String, to_port : int):
	if(connections.has(from)):
		connections[from][from_port] = {"to": to, "to_port": to_port}
	

func disconnect_node(from : String, from_port : int):
	connections[from].erase(from_port)
	
	if(connections[from].is_empty()):
		connections.erase(from)


func remove_node_connections(from : String, connection_list : Array[Dictionary]):
	connections.erase(from)
	
	for dict in connection_list:
		if(dict.to == from):
			connections[dict.from].erase(dict.from_port)


func open_from_path(path : String):
#	print_debug("opening file '%s'" % [path])
	var file := FileAccess.open(path, FileAccess.READ)
	var dict = from_json(file.get_as_text())
#	print_debug("dialogue(%s)" % JSON.stringify(dict, "\t", false))
	
	if(!dict.has("connections") || !dict.has("root_node") || !dict.has("root_node") || !dict.has("nodes") || !(dict.nodes is Dictionary) || !dict.has("variables")): 
		push_error("Unable to load file from path['%s']. Invalid formatting." % [path])
		return
	
	if(dict.connections is Array):
		connections = connection_dict(dict.connections)
	else:
		connections = dict.connections
	variables = dict.variables
	root_node = dict.root_node
	nodes = dict.nodes
	self.path = path


func from_json(text : String):
	var json = JSON.new()
	var error = json.parse(text)
	if(error):
		push_error("Unable to parse json text")
		return
	
	var data = json.data
	if(typeof(data) != TYPE_DICTIONARY):
		push_error("Incoming file must be a dictionary, was '%s'" % [typeof(data)])
		return 
	
#	print_debug("dialogue(%s)" % JSON.stringify(data, "\t", false))
	return data as Dictionary


func _to_string():
	return { path: 
		{
			"connections": connections,
			"variables": variables,
			"root_node": root_node,
			"nodes": nodes
		}
	}
