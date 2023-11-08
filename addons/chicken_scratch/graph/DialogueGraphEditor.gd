@tool
class_name DialogueGraphEditor extends VBoxContainer



#@export var dialogue_node_template : PackedScene;
@export var Graph : DialogueGraph;
@export var FileMenu : MenuButton;
@export var Filename : Label;

@export var root_node_scn : PackedScene;
@export var dialogue_node : PackedScene;
@export var variable_value : PackedScene;

@export var right_click_menu : PopupMenu;
@export var delete_confirmation : ConfirmationDialog;
@export var dialogue_preview : Window;

@export var test_variables_container : Control;
@export var test_variables : Control;

var root_node : RootNode;
var previewed_node : DialogueNode;

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

static var save_pretty := false;
 

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
	OpenFileDialog.add_filter("*.json", "JSON file");
	OpenFileDialog.file_selected.connect(_on_open_file);
	add_child(OpenFileDialog);
	
	SaveFileDialog = EditorFileDialog.new();
	SaveFileDialog.size = Vector2i(800, 400);
	SaveFileDialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE;
	SaveFileDialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS;
#	SaveFileDialog.transient = true;
	SaveFileDialog.add_filter("*.dngraph", "DialogueNode Graph");
	SaveFileDialog.add_filter("*.json", "JSON file");
	SaveFileDialog.file_selected.connect(_on_save_file);
	add_child(SaveFileDialog);


func _set_root_node(node):
	if(root_node != null) :
		push_warning("Root node already set - [%s]" % [root_node]);
		return;

	root_node = node;


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


func get_variables() -> Dictionary:
	var dict := {};
	for variable in test_variables.get_children():
		print_debug("v = %s" % [variable.as_dict()]);
		dict[variable.var_name()] = variable.as_dict();
	
	return dict;


# from graph to json
func graph_to_json(indent := ""):
	# TODO: have a DialogueGraphFile extends RefCounted that keeps track of currently loaded file?
#	print_debug("Graph %s, %s" % [Graph, JSON.stringify(connection_dict(), "\t", false)]);
	var graph := {
		"connections": Graph.get_connection_list(),
		"variables": get_variables(),
		"root_node": root_node.to_dict(),
		"nodes": get_graph_node_dicts()
	};
	
	var json := JSON.stringify(graph, indent, false);
	return json;


func new_dialogue_graph():
	right_click_menu.hide();
	var popup := FileMenu.get_popup();
	if(!popup.id_pressed.is_connected(_on_file_menu_opened)):
		popup.id_pressed.connect(_on_file_menu_opened);
	for i in popup.item_count:
		file_menu_items[i] = popup.get_item_text(i);
	print_debug("file_menu_items=%s" % [file_menu_items]);
	
	dialogue_preview.get_node("%Text").text = "";
	dialogue_preview.hide();
	previewed_node = null;
	node_dict.clear();
	nodes_to_delete.clear();
	selected_nodes.clear();
	current_file_path = "";
	Filename.text = "[empty]";
	
	test_variables_container.hide();
	for child in test_variables.get_children():
		remove_dialogue_variable(child);

	for connections in Graph.get_connection_list():
		Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
	
	for child in Graph.get_children():
		child.free();
		
	if(root_node):
		root_node.queue_free();
	add_root_node();


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


func add_root_node():
	root_node = root_node_scn.instantiate();
	root_node.slots_removed.connect(_on_graph_node_slots_removed);
	Graph.add_child(root_node);


func root_from_dict(dict : Dictionary):
	add_root_node();
	root_node.set_from_dict(dict);


func node_from_dict(dict: Dictionary) -> DialogueNode:
	var new_node = add_new_node();
	new_node.from_dict(dict);
	
	return new_node;


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


func add_new_node(position := Vector2(0, 0)) -> DialogueNode:
	var new_node : DialogueNode = dialogue_node.instantiate();
#	print_debug("asf %s" % [str(new_node.name).replace("@", "_")]);
	new_node.node_close_request.connect(_on_graph_node_close_request);
	new_node.slots_removed.connect(_on_graph_node_slots_removed);
	new_node.preview_pressed.connect(_on_dialogue_node_preview);
	Graph.add_child(new_node);
	new_node.name = new_node.name.replace("@", "_");
#	print_debug("add new node=%s, %s" % [position, new_node]);
#	new_node.global_position = position;
	new_node.position_offset = position;
	node_dict[new_node.name] = new_node; # cache node names
	
	return new_node;
#	print_debug("add - node_dict=%s" % [node_dict]);
#	print_debug("new_node - %s, %s, %s, %s" % [position, new_node.position, new_node.global_position, new_node.position_offset]);


func add_dialogue_variable() -> VariableValue:
	var v : VariableValue = variable_value.instantiate();
	v.delete_requested.connect(_on_variable_delete_requested);
	v.value_changed.connect(_on_variable_value_changed);
	test_variables.add_child(v);
	return v;


func remove_dialogue_variable(variable : VariableValue):
	variable.queue_free();


func close_preview():
	if(previewed_node):
#		for variable in test_variables.get_children():
#			variable.variable_changed.disconnect(_on_variable_value_changed);
		previewed_node.text_changed.disconnect(_on_dialogue_node_text_changed);
		previewed_node = null;
		
	dialogue_preview.hide();


func disconnect_node(node : DialogueNode, from_port : int):
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
		if(connections.from == node.name && connections.from_port == from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);


func close_node(node : DialogueNode):
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
		if(connections.from == node.name || connections.to == node.name):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
	
	if(node == previewed_node):
		close_preview();
	
	Graph.node_deselected.emit(node); # closed node needs to be deselected
	node_dict.erase(node.name);
	node.close_node();
#	print_debug("del - node_dict=%s" % [node_dict]);


func update_preview_text(text : String):
	dialogue_preview.get_node("%Text").text = text;


func update_dialogue_preview():
	var text := previewed_node.text();
	var variables := previewed_node.dialogue_variables;
	var vars := get_variables();
	for variable_name in vars:
		text = text.replace("${%s}" % variable_name, str(vars[variable_name].value));
	
	update_preview_text(text);


func swap_dialogue_preview(node : DialogueNode):
	if(node == previewed_node): return;
	
	var text := node.text();
	var variables := node.dialogue_variables;
	var vars := get_variables();
	for variable_name in vars:
		text = text.replace("${%s}" % variable_name, str(vars[variable_name].value));
	
	if(previewed_node != null):
		previewed_node.text_changed.disconnect(_on_dialogue_node_text_changed);
	
	previewed_node = node;
	node.text_changed.connect(_on_dialogue_node_text_changed);
	
	update_preview_text(text);


func _on_file_menu_opened(id : int):
	print_debug("opening file menu - %s" % [id]);
	match id:
		0: # New Graph
			new_dialogue_graph();
		1: # Open
			OpenFileDialog.show();
		2: # Save
			save_pretty = false;
			SaveFileDialog.show();
		3: # Save Pretty
			save_pretty = true;
			SaveFileDialog.show();


func _on_open_file(path : String):
	print_debug("opening file '%s'" % [path]);
	var file := FileAccess.open(path, FileAccess.READ);
	var dict = from_json(file.get_as_text());
	print_debug("dialogue(%s)" % JSON.stringify(dict, "\t", false));
	
	if(!dict.has("connections") || !dict.has("root_node") || !dict.has("root_node") || !dict.has("nodes") || !(dict.connections is Array) || !(dict.nodes is Array)): 
		push_error("Unable to load file. Invalid formatting.");
		return;
	
	if(dict.has("variables") && dict.variables.size() > 0):
		test_variables_container.show();
		for child in test_variables.get_children():
			test_variables.remove_child(child);
		
		for variable in dict.variables:
			var v := add_dialogue_variable();
			v.from_dict(dict.variables[variable]);
	
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
	file.store_string(graph_to_json("\t" if save_pretty else ""));
	save_pretty = false;


func _on_graph_connection_request(from_node, from_port, to_node, to_port):
	print_debug("connection request - [%s, %s, %s ,%s]" % [from_node, from_port, to_node, to_port]);
	Graph.connect_node(from_node, from_port, to_node, to_port);


func _on_graph_disconnection_request(from_node, from_port, to_node, to_port):
	Graph.disconnect_node(from_node, from_port, to_node, to_port);


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
func _on_graph_node_slots_removed(node : GraphNode, from_port : int):
#	print_debug("node slot[%s] removed - %s, %s" % [from_port, node, Graph.get_connection_list()]);
	
	for connections in Graph.get_connection_list():
		if(connections.from == node.name && connections.from_port == from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
			
	for connections in Graph.get_connection_list():
		if(connections.from == node.name && connections.from_port > from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
			Graph.connect_node(connections.from, connections.from_port - 1, connections.to, connections.to_port);


## Shows a dialogue preview node when the preview button is pressed on a DialogueNode
func _on_dialogue_node_preview(node : DialogueNode):
	print_debug("Preview: %s, %s" % [node.text, node.dialogue_variables]);
	Graph.set_selected(node);
	selected_nodes.clear();
	selected_nodes[node] = true;
	swap_dialogue_preview(node);
	dialogue_preview.show();


func _on_window_close_requested():
	print_debug("close preview window");
	close_preview();


func _on_dialogue_node_text_changed(node : DialogueNode, text : String, variables : Dictionary):
	var vars := get_variables();
	for variable_name in vars:
		text = text.replace("${%s}" % variable_name, str(vars[variable_name].value));
	
	update_preview_text(text);


func _on_variable_value_changed(name : String, value):
	if(previewed_node != null):
		update_dialogue_preview();


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
	if(dialogue_preview.visible):
		swap_dialogue_preview(node);
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


func _on_toggle_show_variables_pressed():
	test_variables_container.visible = !test_variables_container.visible;
	

func _on_add_variable_pressed():
	add_dialogue_variable();


func _on_variable_delete_requested(node : Node):
	remove_dialogue_variable(node);
