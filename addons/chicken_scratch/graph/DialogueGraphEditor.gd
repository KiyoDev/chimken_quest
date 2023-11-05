@tool
class_name DialogueGraphEditor extends VBoxContainer



#@export var dialogue_node_template : PackedScene;
@export var Graph : DialogueGraph;
@export var FileMenu : MenuButton;
@export var Filename : Label;

@export var root_node_scn : PackedScene;
@export var dialogue_node : PackedScene;
@export var right_click_menu : PopupMenu;
@export var delete_confirmation : ConfirmationDialog;

var root_node : RootNode;

var node_dict : Dictionary = {};
var file_menu_items : Dictionary = {};
var nodes_to_delete : Array[StringName] = [];

var selected_nodes := {};
var to_copy : Array[Dictionary] = [];

var current_file_path : String = "";

var new_node_position := Vector2();

static var OpenFileDialog : EditorFileDialog;
static var SaveFileDialog : EditorFileDialog;

# TODO: open DialogueFile from disk and populate graph (adding nodes, adding connections, etc)
static var current_dialogue_file : DialogueFile;
 

func _ready():
	print_debug("ready");


func _enter_tree():
	print_debug("enter tree");


func _exit_tree():
	right_click_menu.hide();


func _notification(what):
	if(what == NOTIFICATION_WM_CLOSE_REQUEST ): 
		if(root_node):
			root_node.queue_free();
			root_node = null;
#		var popup := FileMenu.get_popup();
#		popup.id_pressed.disconnect(_on_file_menu_opened);
		OpenFileDialog.queue_free();
		SaveFileDialog.queue_free();


func on_plugin_start():
	new_dialogue_graph();
	
	# init EditorFileDialogs
	OpenFileDialog = EditorFileDialog.new();
	OpenFileDialog.title = "Open a DialogueNode graph";
	OpenFileDialog.size = Vector2i(800, 400);
	OpenFileDialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE;
	OpenFileDialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS;
#	OpenFileDialog.transient = true;
	OpenFileDialog.add_filter("*.dngraph", "DialogueNode Graph");
	OpenFileDialog.file_selected.connect(_on_open_file);
	add_child(OpenFileDialog);
	
	SaveFileDialog = EditorFileDialog.new();
	SaveFileDialog.size = Vector2i(800, 400);
	SaveFileDialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE;
	SaveFileDialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS;
#	SaveFileDialog.transient = true;
	SaveFileDialog.add_filter("*.dngraph", "DialogueNode Graph");
	SaveFileDialog.file_selected.connect(_on_save_file);
	add_child(SaveFileDialog);


func _set_root_node(node):
	if(root_node != null) :
		push_warning("Root node already set - [%s]" % [root_node]);
		return;

	root_node = node;


func new_dialogue_graph():
	right_click_menu.hide();
	var popup := FileMenu.get_popup();
	if(!popup.id_pressed.is_connected(_on_file_menu_opened)):
		popup.id_pressed.connect(_on_file_menu_opened);
	for i in popup.item_count:
		file_menu_items[i] = popup.get_item_text(i);
	print_debug("file_menu_items=%s" % [file_menu_items]);
	
	node_dict.clear();
	nodes_to_delete.clear();
	selected_nodes.clear();
	current_file_path = "";
	
	for connections in Graph.get_connection_list():
		Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
	
	for child in Graph.get_children():
		child.free();
	root_node = root_node_scn.instantiate();
	Graph.add_child(root_node);


# from graph to json
func graph_to_json(indent := ""):
	# TODO: have a DialogueGraphFile extends RefCounted that keeps track of currently loaded file?
#	print_debug("Graph %s, %s" % [Graph, JSON.stringify(connection_dict(), "\t", false)]);
	var graph := {
		"connections": Graph.get_connection_list(),
		"root_node": root_node.to_dict(),
		"nodes": get_graph_node_dicts()
	};
	
	var json := JSON.stringify(graph, indent, false);
	return json;


func from_json(text : String):
	var json = JSON.new();
	var error = json.parse(text);
	if(error):
		push_error("Unable to parse json text");
		return;
	
	var data = json.data;
	if(typeof(data) != TYPE_DICTIONARY):
		push_error("Incoming file must be a dictionary, was '%s'" % [typeof(data)]);
		return; 
	
#	print_debug("dialogue(%s)" % JSON.stringify(data, "\t", false));
	return data as Dictionary;


func connection_dict() -> Dictionary:
	var connections := {};
	for connection in Graph.get_connection_list():
		if(!connections.has(connection.from)):
#			print_debug("add new connection to dict");
			connections[connection.from] = {};
		# support multiple connections at same "from_port"?
		connections[connection.from][connection.from_port] = {"to": connection.to, "to_port": connection.to_port};
	
	return connections;


func get_graph_node_dicts() ->  Array[Dictionary]:
	var nodes : Array[Dictionary] = [];
	# ignore root node
	for i in range(0, Graph.get_child_count()):
		if(Graph.get_child(i) is RootNode): continue;
		nodes.append(Graph.get_child(i).to_dict());
	return nodes;


func add_new_node(position := Vector2(0, 0)) -> DialogueNode:
	var new_node : DialogueNode = dialogue_node.instantiate().clone_from_template();
#	var new_node : DialogueNode = dialogue_node.instantiate().duplicate(0b0111).empty();
#	print_debug("asf %s" % [str(new_node.name).replace("@", "_")]);
	new_node.node_close_request.connect(_on_graph_node_close_request);
	new_node.slots_removed.connect(_on_graph_node_slots_removed);
	Graph.add_child(new_node);
	new_node.name = new_node.name.replace("@", "_");
#	print_debug("add new node=%s, %s" % [position, new_node]);
#	new_node.global_position = position;
	new_node.position_offset = position;
	node_dict[new_node.name] = new_node; # cache node names
	
	return new_node;
#	print_debug("add - node_dict=%s" % [node_dict]);
#	print_debug("new_node - %s, %s, %s, %s" % [position, new_node.position, new_node.global_position, new_node.position_offset]);


func init_nodes_from_json(dict : Dictionary):
	print_debug("json %s" % [dict]);
	node_dict.clear();
	file_menu_items.clear();
	nodes_to_delete.clear();
	Graph.clear_connections();
	
	for child in Graph.get_children():
		child.free();

	root_from_dict(dict.root_node);

	for node in dict.nodes:
		node_from_dict(node);
	
	for connection in dict.connections:
#		print_debug("reconnect - [%s, %s] -> [%s, %s]" % [connection.from, connection.from_port, connection.to, connection.to_port]);
		await get_tree().create_timer(0.001).timeout
		Graph.connect_node(connection.from, connection.from_port, connection.to, connection.to_port);


func root_from_dict(dict : Dictionary):
	root_node = root_node_scn.instantiate();
	Graph.add_child(root_node);
	root_node.set_from_dict(dict);


func node_from_dict(dict: Dictionary) -> DialogueNode:
	var node := DialogueNode.new_from_dict(dialogue_node, dict, Graph);
#	print_debug("from d  %s" % [node]);
	
	node.node_close_request.connect(_on_graph_node_close_request);
	node.slots_removed.connect(_on_graph_node_slots_removed);
	node_dict[node.name] = node; # cache node names
	print_debug("nod 0 %s, %s, %s" % [dict.name, dict.type, node]);
	
	return node;


func _on_file_menu_opened(id : int):
	print_debug("opening file menu - %s" % [id]);
	match id:
		0: # New Graph
			new_dialogue_graph();
		1: # Open
			OpenFileDialog.show();
		2: # Save
			SaveFileDialog.show();
		3: # Save as...
			pass;


func _on_open_file(path : String):
	print_debug("opening file '%s'" % [path]);
	var file := FileAccess.open(path, FileAccess.READ);
	var dict = from_json(file.get_as_text());
	print_debug("dialogue(%s)" % JSON.stringify(dict, "\t", false));
	
	init_nodes_from_json(dict);
	current_file_path = path;
	Filename.text = path.get_file();
	
#	print_debug("root[%s] - %s" % [dict.root_node.name, dict.root_node.metadata.position]);
#	for node in dict.nodes:
#		print_debug("node[%s] - %s" % [node.name, node.metadata.position]);
	# new_graph
#	var content = file.get_as_text();
#	return content;


func _on_save_file(path : String):
	print_debug("saving file '%s'" % [path]);
	var file := FileAccess.open(path, FileAccess.WRITE);
	file.store_string(graph_to_json());


func _on_graph_connection_request(from_node, from_port, to_node, to_port):
	print_debug("connection request - [%s, %s, %s ,%s]" % [from_node, from_port, to_node, to_port]);
	Graph.connect_node(from_node, from_port, to_node, to_port);


func _on_graph_disconnection_request(from_node, from_port, to_node, to_port):
	Graph.disconnect_node(from_node, from_port, to_node, to_port);


func close_node(node : DialogueNode):
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
		if(connections.from == node.name || connections.to == node.name):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
	
	Graph.node_deselected.emit(node); # closed node needs to be deselected
	node_dict.erase(node.name);
	node.close_node();
#	print_debug("del - node_dict=%s" % [node_dict]);


# TODO: figure out if theres a better way than looping through every node connection... maybe connect nodes to eachother to close those connections if the neighbor closes.
# Removes all connections related to the closed node
func _on_graph_node_close_request(node : DialogueNode):
	print_debug("node close request - %s, %s" % [node, Graph.get_connection_list()]);
	nodes_to_delete.clear();
	nodes_to_delete.append(node.name);
	delete_confirmation.show();
	
#	for connections in Graph.get_connection_list():
##		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
#		if(connections.from == node.name || connections.to == node.name):
#			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
#
#	node_dict.erase(node.name);
#	print_debug("del - node_dict=%s" % [node_dict]);


## When DailogueNode slots change
func _on_graph_node_slots_removed(node : DialogueNode, from_port : int):
#	print_debug("node slot[%s] removed - %s, %s" % [from_port, node, Graph.get_connection_list()]);
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
		if(connections.from == node.name && connections.from_port == from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);


## Right click menu
func _on_graph_popup_request(position):
	print_debug("_on_graph_popup_request - %s" % [position]);
#	if(!right_click_menu_open):
#	right_click_menu.set_position(position);
	new_node_position = Vector2i(position);
	right_click_menu.set_position(Vector2(position.x + 302, position.y + 142));
	right_click_menu.show();


func _on_right_click_menu_gui_input(event):
	if(event is InputEventMouseButton):
		if(event.is_pressed()):
			print_debug("right click menu input %s " % [event]);


func _on_graph_gui_input(event):
	pass;
#	if(event is InputEventMouseButton):
#		if(event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT):


func _on_graph_delete_nodes_request(nodes):
	print_debug("graph delete request - %s" % [nodes]);
	nodes_to_delete = nodes;
	delete_confirmation.show();

# TODO: undoredo


func _on_graph_tree_entered():
	print_debug("entering graph");


func _on_graph_tree_exited():
	print_debug("exiting graph");


func _on_root_node_scn_pressed():
	print_debug("Add root node");


func _on_print_pressed():
	print_debug(graph_to_json("\t"));


func _on_delete_confirmation_dialog_confirmed():
	for name in nodes_to_delete:
		var node = node_dict[name];
		close_node(node);
	nodes_to_delete.clear();


func _on_delete_confirmation_dialog_canceled():
	nodes_to_delete.clear();


func _on_graph_node_selected(node):
	selected_nodes[node] = true;
	print_debug("Selected '%s' - %s" % [node.name, selected_nodes]);


func _on_graph_node_deselected(node):
	selected_nodes.erase(node);
#	print_debug("Deselected '%s' -  %s" % [node.name, selected_nodes]);


# TODO: append node.to_dict() to array
func _on_graph_copy_nodes_request():
	print_debug("graph copy request: trying to copy nodes - %s" % [selected_nodes]);
#	if(selected_nodes.is_empty()): return; # TODO: do want to clear copy by trying to copy nothing?
	
	to_copy.clear();
	for node in selected_nodes:
		if(node is RootNode): continue; # do not copy root node
		to_copy.append(node.to_dict());


# TODO: take node.to_dict() array and instantiate new node from dict
func _on_graph_paste_nodes_request():
	print_debug("graph paste request: trying to paste nodes - %s" % [to_copy]);
	
	for node in selected_nodes.keys():
		node.selected = false;
		node.node_deselected.emit();
		selected_nodes.erase(node);
		
	for dict in to_copy:
		var node := node_from_dict(dict);
		node.position_offset = Vector2(node.position_offset.x + Graph.snap_distance, node.position_offset.y + Graph.snap_distance);
		node.selected = true;
		node.node_selected.emit();


func _on_graph_duplicate_nodes_request():
	print_debug("Duplcate requested");


func _on_right_click_menu_id_pressed(id : int):
	print_debug("opening file menu - %s" % [id]);
	match id:
		0: # New Graph
			print_debug("new_node_pressed - %s" % [right_click_menu.position]);
			# Add scroll offset and apply zoom value to position
			add_new_node((new_node_position + Graph.scroll_offset) / Graph.zoom);
			right_click_menu.hide();
