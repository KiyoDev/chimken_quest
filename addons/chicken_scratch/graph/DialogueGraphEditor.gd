@tool
class_name DialogueGraphEditor extends VBoxContainer


enum DialogType {
	OPEN_GRAPH,
	SAVE_GRAPH,
	CHANGE_THEME
}


@export var Graph : DialogueGraph
@export var FileMenu : MenuButton
@export var Filename : Label

@export var root_node_scn : PackedScene
@export var dialogue_node : PackedScene
@export var variable_value : PackedScene

@export var right_click_menu : PopupMenu
@export var delete_confirmation : ConfirmationDialog
@export var dialogue_preview : Window

@export var test_variables_container : Control
@export var test_variables : Control

@export var dialogue_box_scn : PackedScene
@export var dialogue_box_preview_scn : PackedScene

var root_node : RootNode
var previewed_node : DialogueNode
var dialogue_box : DialogueBox

var dialogue_box_preview : DialogueBoxPreview

var node_dict : Dictionary = {}
var file_menu_items : Dictionary = {}
var nodes_to_delete : Array[StringName] = []

var selected_nodes := {}
var to_copy : Array[Dictionary] = []

var current_file_path : String = ""

var new_node_position := Vector2()

var dialog : EditorFileDialog

static var save_pretty := false

static var settings := {
	"current_tree": ""
}

func _ready():
	print_debug("ready")
	var popup := FileMenu.get_popup()
	if(!popup.id_pressed.is_connected(_on_file_menu_opened)):
		popup.id_pressed.connect(_on_file_menu_opened)
#
	for i in popup.item_count:
		file_menu_items[i] = popup.get_item_text(i)


func _enter_tree():
	print_debug("enter tree")


func _exit_tree():
	right_click_menu.hide()


func _notification(what):
	if(what == NOTIFICATION_WM_CLOSE_REQUEST ): 
		if(root_node):
			root_node.queue_free()
			root_node = null
#		var popup := FileMenu.get_popup()
#		popup.id_pressed.disconnect(_on_file_menu_opened)


func on_plugin_start():
	# init EditorFileDialogs
		
#	ChickenScratch.dialogue_finished.connect(_on_dialogue_player_finished)

#	print_debug("file_menu_items=%s" % [file_menu_items])
#	print_debug("Graph.get_rect().end=%s" % [Graph.get_parent().get_rect().end])
	
#	dialogue_box_preview.hide()
	
	new_dialogue_graph(Vector2(380, 380))


func open_dialog(type):
	dialog = EditorFileDialog.new()
	dialog.size = Vector2i(800, 400)
	dialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	add_child(dialog)
	dialog.close_requested.connect(_on_dialog_close_requested)
	
	match(type):
		DialogType.OPEN_GRAPH:
			dialog.title = "Open a DialogueNode graph"
			dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
			dialog.add_filter("*.dngraph", "DialogueNode Graph")
			dialog.add_filter("*.json", "JSON file")
			dialog.file_selected.connect(_on_open_file)
		DialogType.SAVE_GRAPH:
			dialog.title = "Save DialogueNode graph"
			dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
			dialog.add_filter("*.dngraph", "DialogueNode Graph")
			dialog.add_filter("*.json", "JSON file")
			dialog.file_selected.connect(_on_save_file)
		DialogType.CHANGE_THEME:
			dialog.title = "Change UI theme"
			dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
			dialog.add_filter("*.theme", "UI Theme")
			dialog.file_selected.connect(_on_change_theme)
	
	dialog.show()


func _on_dialog_close_requested():
	dialog.queue_free()


func _on_theme_dropped(files: PackedStringArray):
	print(files)
	

func _set_root_node(node):
	if(root_node != null) :
		push_warning("Root node already set - [%s]" % [root_node])
		return

	root_node = node


func connection_dict() -> Dictionary:
	var connections := {}
	for connection in Graph.get_connection_list():
		if(!connections.has(connection.from)):
#			print_debug("add new connection to dict")
			connections[connection.from] = {}
		# support multiple connections at same "from_port"?
		connections[connection.from][connection.from_port] = {"to": connection.to, "to_port": connection.to_port}
	
	return connections


func get_graph_node_dicts() ->  Dictionary:
	var nodes := {}
	# ignore root node
	for i in range(0, Graph.get_child_count()):
		if(Graph.get_child(i) is RootNode): continue
		var dict : Dictionary = Graph.get_child(i).to_dict()
		nodes[dict.name] = dict
	return nodes


# Variables from all nodes
func get_variable_list() -> Array:
	var vars := {}
	for i in range(0, Graph.get_child_count()):
		if(Graph.get_child(i) is RootNode): continue
		var node : DialogueNode = Graph.get_child(i)
		
		for variable in node.get_variables():
			vars[variable] = true
	
	return vars.keys()


# Variables specific to this GraphEdit
func get_graph_variables() -> Dictionary:
	var dict := {}
	for variable in test_variables.get_children():
		dict[variable.var_name()] = variable.value()
	
	return dict


func get_variables_parsed() -> Dictionary:
	var dict := {}
	for variable in test_variables.get_children():
		dict[variable.var_name()] = variable.value()
	
	return dict


func graph_to_dict() -> Dictionary:
	return {
#		"connections": Graph.get_connection_list(),
		"connections": ChickenScratch.dialogue_tree.connections,
		"variables": ChickenScratch.variables,
		"root_node": root_node.to_dict(),
		"nodes": get_graph_node_dicts()
	}


# from graph to json
func graph_to_json(indent := ""):
#	print_debug("Graph %s, %s" % [Graph, JSON.stringify(connection_dict(), "\t", false)])
	
	if(!root_node):
		print_debug("no root node detected")
		return ""
	
	var json := JSON.stringify(graph_to_dict(), indent, false)
	return json


func new_dialogue_graph(root_position := Vector2()):
	if(!ChickenScratch.dialogue_finished.is_connected(_on_dialogue_player_finished)):
		ChickenScratch.dialogue_finished.connect(_on_dialogue_player_finished)
	Graph.clear_connections()

	for child in test_variables.get_children():
		remove_dialogue_variable(child)

	for child in Graph.get_children():
		child.queue_free() # free all graph nodes

	right_click_menu.hide()
	dialogue_preview.get_node("Container/VBoxContainer/PreviewText").text = ""
	dialogue_preview.hide()
	previewed_node = null
	node_dict.clear()
	nodes_to_delete.clear()
	selected_nodes.clear()
	current_file_path = ""
	Filename.text = "[empty]"
	test_variables_container.hide()
	
	add_root_node(root_position)


func init_nodes_from_tree():
	print_debug("From tree - %s" % [ChickenScratch.dialogue_tree.nodes])
	node_dict.clear()
	file_menu_items.clear()
	nodes_to_delete.clear()
	Graph.clear_connections()
	
	for child in Graph.get_children():
		child.free()

	root_from_dict(ChickenScratch.dialogue_tree.root_node)

#	for node in dict.nodes:
#		node_from_dict(node)

	for key in ChickenScratch.dialogue_tree.nodes:
		print_debug("nodddd - %s" % [key])
		node_from_dict(ChickenScratch.dialogue_tree.nodes[key])
	
	# {"name": { <from_port>: { "to": <name>, "to_port": <to_port> } }}
	for from in ChickenScratch.dialogue_tree.connections:
#		print_debug("reconnect - [%s, %s] -> [%s, %s]" % [connection.from, connection.from_port, connection.to, connection.to_port])
		await get_tree().create_timer(0.001).timeout
		for from_port in ChickenScratch.dialogue_tree.connections[from]:
			var to_info = ChickenScratch.dialogue_tree.connections[from][from_port]
			Graph.connect_node(from, int(from_port), to_info.to, to_info.to_port)


func init_nodes_from_dict(dict : Dictionary):
	print_debug("json %s" % [dict])
	node_dict.clear()
	file_menu_items.clear()
	nodes_to_delete.clear()
	Graph.clear_connections()
	ChickenScratch.dialogue_tree.connections.clear()
	
	for child in Graph.get_children():
		child.free()

	root_from_dict(dict.root_node)

#	for node in dict.nodes:
#		node_from_dict(node)

	for key in dict.nodes:
		node_from_dict(dict.nodes[key])
	
	# {"name": { <from_port>: { "to": <name>, "to_port": <to_port> } }}
	for from in dict.connections:
#		print_debug("reconnect - [%s, %s] -> [%s, %s]" % [connection.from, connection.from_port, connection.to, connection.to_port])
		await get_tree().create_timer(0.001).timeout
		for from_port in ChickenScratch.dialogue_tree.connections[from]:
			var to_info = ChickenScratch.dialogue_tree.connections[from][from_port]
			Graph.connect_node(from, from_port, to_info.to, to_info.to_port)
#		Graph.connect_node(connection.from, connection.from_port, connection.to, connection.to_port)


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


func add_root_node(position := Vector2(0, 0)) -> RootNode:
	root_node = root_node_scn.instantiate()
	root_node.slots_removed.connect(_on_graph_node_slots_removed)
	root_node.branch_play_requested.connect(_on_branch_play_requested)
	Graph.add_child(root_node)
	print("ro %s" % [root_node.custom_minimum_size])
	root_node.position_offset = position - Vector2(75, 55)
	
	return root_node


func root_from_dict(dict : Dictionary) -> RootNode:
	add_root_node()
	root_node.set_from_dict(dict)
	
	return root_node


func add_new_node(position := Vector2(0, 0)) -> DialogueNode:
	var new_node : DialogueNode = dialogue_node.instantiate()
	new_node.show()
	new_node.node_close_requested.connect(_on_graph_node_close_requested)
	new_node.slots_removed.connect(_on_graph_node_slots_removed)
	new_node.preview_pressed.connect(_on_dialogue_node_preview)
	new_node.play_pressed.connect(_on_dialogue_node_play)
	new_node.node_updated.connect(_on_dialogue_node_updated)
	
	Graph.add_child(new_node)
	new_node.name = new_node.name.replace("@", "_")
	new_node.position_offset = position
	node_dict[new_node.name] = new_node # cache node names
	
	print_debug("new node - %s" % [new_node])
	print_debug("Graph - %s" % [Graph.get_children()])
	
	return new_node


func node_from_dict(dict: Dictionary) -> DialogueNode:
	var new_node = add_new_node()
	new_node.from_dict(dict)
	
	return new_node


func add_dialogue_variable() -> VariableValue:
	var v : VariableValue = variable_value.instantiate()
	v.name_changed.connect(_on_variable_name_changed)
	v.delete_requested.connect(_on_variable_delete_requested)
	v.value_changed.connect(_on_variable_value_changed)
	test_variables.add_child(v)
	return v


func update_variable_name(old : String, new : Variant):
	ChickenScratch.update_variable_name(old, new)

func update_variable_value(name : String, value : Variant):
	ChickenScratch.update_variable_value(name, value)
	


func remove_dialogue_variable(variable : VariableValue):
	variable.queue_free()
	ChickenScratch.delete_variable(variable.var_name())


func close_preview():
	if(previewed_node):
#		for variable in test_variables.get_children():
#			variable.variable_changed.disconnect(_on_variable_value_changed)
		previewed_node.text_changed.disconnect(_on_dialogue_node_text_changed)
		previewed_node = null
		
	dialogue_preview.hide()


func disconnect_node(node : DialogueNode, from_port : int):
	ChickenScratch.dialogue_tree.disconnect_node(node.name, from_port)
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)])
		if(connections.from == node.name && connections.from_port == from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port)
	


func close_node(node : DialogueNode):
	ChickenScratch.dialogue_tree.remove_node_connections(node.name, Graph.get_connection_list())
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)])
		if(connections.from == node.name || connections.to == node.name):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port)
	
	
	if(node == previewed_node):
		close_preview()
	
	Graph.node_deselected.emit(node) # closed node needs to be deselected
	node_dict.erase(node.name)
	node.close_node()
	ChickenScratch.dialogue_tree.nodes.erase(node.name)


# TODO: support changing node names?
func update_dialogue_tree(node : DialogueNode):
	ChickenScratch.dialogue_tree.nodes[node.name] = node.to_dict()
	ChickenScratch.dialogue_tree.connections = connection_dict()


func update_preview_text(text : String):
	dialogue_preview.get_node("Container/VBoxContainer/PreviewText").text = text


func update_dialogue_preview():
	var text := previewed_node.text()
	var variables := previewed_node.dialogue_variables
	var vars := get_graph_variables()
	for variable_name in vars:
		text = text.replace("${%s}" % variable_name, str(vars[variable_name].value))
	
	update_preview_text(text)


func swap_dialogue_preview(node : DialogueNode):
	if(node == previewed_node): return
	
	
	var text := node.text()
	var variables := node.dialogue_variables
	var vars := get_graph_variables()
	
#	for variable_name in vars:
#		text = text.replace("${%s}" % variable_name, str(vars[variable_name]))

	if(previewed_node != null):
		previewed_node.text_changed.disconnect(_on_dialogue_node_text_changed)
	
	previewed_node = node
	node.text_changed.connect(_on_dialogue_node_text_changed)
	
	update_preview_text(ChickenScratch.VariableHandler.parse_text(text))


func _on_file_menu_opened(id : int):
	print_debug("opening file menu - %s" % [id])
	match id:
		0: # New Graph
			print("rect %s, %s" %[Graph.global_position, Graph.get_rect().end/2])
			new_dialogue_graph(Graph.get_rect().end/2)
		1: # Open
			open_dialog(DialogType.OPEN_GRAPH)
		2: # Save
			save_pretty = false
			open_dialog(DialogType.SAVE_GRAPH)
		3: # Save Pretty
			save_pretty = true
			open_dialog(DialogType.SAVE_GRAPH)


func init_dialogue_box():
	if(dialogue_box != null):
		dialogue_box.queue_free()
		
	dialogue_box = dialogue_box_scn.instantiate()
	dialogue_box.finished_revealing.connect(_on_dialogue_box_finished)


func _on_open_file(path : String):
	print_debug("opening file '%s'" % [path])
#	var file := FileAccess.open(path, FileAccess.READ)
#	var dict = from_json(file.get_as_text())
#	print_debug("dialogue(%s)" % JSON.stringify(dict, "\t", false))
#
#	if(!dict.has("connections") || !dict.has("root_node") || !dict.has("root_node") || !dict.has("nodes") || !(dict.connections is Array) || !(dict.nodes is Dictionary)): 
#		push_error("Unable to load file. Invalid formatting.")
#		return
	
#	if(dict.has("variables") && dict.variables.size() > 0):

	init_dialogue_box()
	
	EditorUtil.set_editor_setting("current_tree", path)
	ChickenScratch.preload_tree(path, dialogue_box)
	
	print("NEW TREE - %s" % [EditorUtil.get_editor_setting("current_tree")])
	
	test_variables_container.show()
	for child in test_variables.get_children():
		test_variables.remove_child(child)
	
	for variable in ChickenScratch.variables:
#		ChickenScratch.variables[variable] = dict.variables[variable]
		var v := add_dialogue_variable()
		v.set_variable(variable, ChickenScratch.variables[variable])
#			v.from_dict(dict.variables[variable])

	init_nodes_from_tree()
	current_file_path = path
	Filename.text = path.get_file()


func _on_save_file(path : String):
	print_debug("saving file '%s'" % [path])
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(graph_to_json("\t" if save_pretty else ""))
	save_pretty = false


func _on_graph_connection_request(from_node, from_port, to_node, to_port):
	print_debug("connection request - [%s, %s, %s ,%s]" % [from_node, from_port, to_node, to_port])
	# TODO: check if from_port connection already exists, else don't connect
	if(!ChickenScratch.dialogue_tree.node_is_connected(from_node, from_port)):
		ChickenScratch.dialogue_tree.connect_node(from_node, from_port, to_node, to_port)
		Graph.connect_node(from_node, from_port, to_node, to_port)
	


func _on_graph_disconnection_request(from_node, from_port, to_node, to_port):
	ChickenScratch.dialogue_tree.disconnect_node(from_node, from_port)
	Graph.disconnect_node(from_node, from_port, to_node, to_port)

# FIXME: update DialogueTree on:
#		add/delete node, update text/speaker, add/remove connection

#region Dialogue Node Callbacks
func _on_dialogue_node_updated(node : DialogueNode):
	print_debug("updating node %s" % node)
	update_dialogue_tree(node)


# TODO: figure out if theres a better way than looping through every node connection... maybe connect nodes to eachother to close those connections if the neighbor closes.
# Removes all connections related to the closed node
func _on_graph_node_close_requested(node : DialogueNode):
	print_debug("node close request - %s, %s" % [node, Graph.get_connection_list()])
	nodes_to_delete.clear()
	nodes_to_delete.append(node.name)
	delete_confirmation.show()


## When DailogueNode slots change
func _on_graph_node_slots_removed(node : GraphNode, from_port : int):
#	print_debug("node slot[%s] removed - %s, %s" % [from_port, node, Graph.get_connection_list()])
	
	for connections in Graph.get_connection_list():
		if(connections.from == node.name && connections.from_port == from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port)
	
	for connections in Graph.get_connection_list():
		if(connections.from == node.name && connections.from_port > from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port)
			Graph.connect_node(connections.from, connections.from_port - 1, connections.to, connections.to_port)


#region Dialogue Play
## Shows a dialogue preview node when the preview button is pressed on a DialogueNode
func _on_dialogue_node_preview(node : DialogueNode):
	print_debug("Preview: %s, %s" % [node.text, node.dialogue_variables])
	Graph.set_selected(node)
	selected_nodes.clear()
	selected_nodes[node] = true
	swap_dialogue_preview(node)
	dialogue_preview.show()
	
	init_dialogue_box()
	ChickenScratch.dialogue_box = dialogue_box
	dialogue_preview.get_node("Container/VBoxContainer").add_child(dialogue_box)
	ChickenScratch.reparent(dialogue_preview)
	ChickenScratch.play_text({
		"type": "Dialogue",
		"speaker": "",
		"text": dialogue_preview.get_node("Container/VBoxContainer/PreviewText").text
		})
#		dialogue_box.load_dialogue(dialogue_preview.get_node("%PreviewText").text)


func _on_dialogue_preview_close_requested():
	print_debug("close preview window")
	ChickenScratch.reparent(get_tree().root)
	ChickenScratch.stop()
	close_preview()
	if(dialogue_box != null):
		dialogue_box.queue_free()


func _on_dialogue_node_play(node : DialogueNode):
	if(ChickenScratch.playing): return
	print_debug("Play: %s, %s" % [node.text(), node.dialogue_variables])
	Graph.set_selected(node)
	selected_nodes.clear()
	selected_nodes[node] = true
	
	dialogue_box_preview = dialogue_box_preview_scn.instantiate()
#	add_child(dialogue_box_preview)
	dialogue_box_preview.show()
	Graph.add_child(dialogue_box_preview)
	dialogue_box_preview.position_offset = ((get_viewport_rect().size / 4) + Graph.scroll_offset) / Graph.zoom
	
	init_dialogue_box()
		
	ChickenScratch.dialogue_box = dialogue_box_preview.dialogue_box
	ChickenScratch.play_at(node.name)


func _on_branch_play_requested(slot : int):
	if(ChickenScratch.started): return
	
	print_debug("playing branch %s" % [slot])
	dialogue_box_preview = dialogue_box_preview_scn.instantiate()
#	add_child(dialogue_box_preview)
	dialogue_box_preview.show()
	Graph.add_child(dialogue_box_preview)
	dialogue_box_preview.position_offset = ((get_viewport_rect().size / 4) + Graph.scroll_offset) / Graph.zoom
	
	ChickenScratch.dialogue_box = dialogue_box_preview.dialogue_box
	ChickenScratch.play_branch(slot)


func _on_dialogue_box_preview_close_requested():
	ChickenScratch.kill()
	dialogue_box_preview.queue_free()


func _on_dialogue_box_finished(dialogue : Dictionary):
	print_debug("dialogue box finished")
	dialogue_box.queue_free()
#	await get_tree().create_timer(0.001).timeout
#	dialogue_preview.reset_size()


## Play the current dialogue tree in a scene
func _on_play_pressed():
	print_debug("playing whole dialogue.")
	var plugin : EditorPlugin
	for child in Engine.get_main_loop().get_root().get_children():
		if child.get_class() == "EditorNode":
			plugin = child.get_node("ChickenScratchPlugin")
			plugin.get_editor_interface().play_custom_scene("res://addons/chicken_scratch/editor/play_scene.tscn")
	return
#	dialogue_box_preview = dialogue_box_preview_scn.instantiate()
##	add_child(dialogue_box_preview)
#	dialogue_box_preview.show()
#	Graph.add_child(dialogue_box_preview)
#	dialogue_box_preview.position_offset = ((get_viewport_rect().size / 4) + Graph.scroll_offset) / Graph.zoom
#	ChickenScratch.dialogue_box = dialogue_box_preview.dialogue_box
#
#	dialogue_box_preview.show()
##	ChickenScratch.load_dialogue_tree(graph_to_dict())
#	ChickenScratch.play_branch(0)


func _on_dialogue_player_finished():
	print_debug("dialogue player finished branch")
	if(dialogue_box_preview != null):
		dialogue_box_preview.queue_free()

# DIALOGUE NODE
func _on_dialogue_node_text_changed(node : DialogueNode, text : String, variables : Dictionary):
	var vars := get_graph_variables()
	for variable_name in vars:
		text = text.replace("${%s}" % variable_name, str(vars[variable_name].value))
	
	update_preview_text(text)


## Right click menu
func _on_graph_popup_request(position):
	print_debug("_on_graph_popup_request - %s" % [position])
	new_node_position = Vector2i(position)
	right_click_menu.set_position(get_global_mouse_position() + Vector2(0, 30))
#	right_click_menu.set_position((Vector2(position.x, position.y) + Graph.scroll_offset) / Graph.zoom)
#	right_click_menu.set_position(Vector2(position.x + 302, position.y + 142) + (Graph.scroll_offset / Graph.zoom))
	right_click_menu.show()


func _on_right_click_menu_gui_input(event):
	if(event is InputEventMouseButton):
		if(event.is_pressed()):
			print_debug("right click menu input %s " % [event])


func _on_graph_gui_input(event):
	pass
#	if(event is InputEventMouseButton):
#		if(event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT):


func _on_graph_delete_nodes_request(nodes):
	print_debug("graph delete request - %s" % [nodes])
	nodes_to_delete = nodes
	delete_confirmation.show()

# TODO: undoredo


func _on_print_pressed():
	print_debug(graph_to_json("\t"))
	print_debug(connection_dict())


func _on_delete_confirmation_dialog_confirmed():
	for name in nodes_to_delete:
		var node = node_dict[name]
		close_node(node)
	nodes_to_delete.clear()


func _on_delete_confirmation_dialog_canceled():
	nodes_to_delete.clear()


func _on_graph_node_selected(node):
	selected_nodes[node] = true
	if(dialogue_preview.visible):
		swap_dialogue_preview(node)
#	print_debug("Selected '%s' - %s" % [node.name, selected_nodes])


func _on_graph_node_deselected(node):
	selected_nodes.erase(node)
#	print_debug("Deselected '%s' -  %s" % [node.name, selected_nodes])


# TODO: append node.to_dict() to array
func _on_graph_copy_nodes_request():
	print_debug("graph copy request: trying to copy nodes - %s" % [selected_nodes])
#	if(selected_nodes.is_empty()): return # TODO: do want to clear copy by trying to copy nothing?
	
	to_copy.clear()
	for node in selected_nodes:
		if(node is RootNode): continue # do not copy root node
		to_copy.append(node.to_dict())


# TODO: take node.to_dict() array and instantiate new node from dict
func _on_graph_paste_nodes_request():
	print_debug("graph paste request: trying to paste nodes - %s" % [to_copy])
	
	for node in selected_nodes.keys():
		node.selected = false
		node.node_deselected.emit()
		selected_nodes.erase(node)
		
	for dict in to_copy:
		var node := node_from_dict(dict)
		node.position_offset = Vector2(node.position_offset.x + Graph.snap_distance, node.position_offset.y + Graph.snap_distance)
		node.selected = true
		node.node_selected.emit()


func _on_graph_duplicate_nodes_request():
	print_debug("Duplcate requested")


func _on_right_click_menu_id_pressed(id : int):
	print_debug("opening file menu - %s" % [id])
	match id:
		0: # New Graph
			print_debug("new_node_pressed - %s" % [right_click_menu.position])
			# Add scroll offset and apply zoom value to position
			add_new_node((new_node_position + Graph.scroll_offset) / Graph.zoom)
			right_click_menu.hide()


func _on_toggle_show_variables_pressed():
	test_variables_container.visible = !test_variables_container.visible
	

func _on_add_variable_pressed():
	add_dialogue_variable()


func _on_variable_delete_requested(variable : VariableValue):
	remove_dialogue_variable(variable)


func _on_variable_value_changed(name : String, value):
	update_variable_value(name, value)
	if(previewed_node != null):
		update_dialogue_preview()


func _on_variable_name_changed(old : String, new : String):
	# get original variable value, remove old mapping, and remap to new name
	update_variable_name(old, new)


func _on_change_theme_pressed():
	open_dialog(DialogType.CHANGE_THEME)
	

func _on_change_theme(path : String):
	var theme : Theme = load(path)
	dialogue_preview.get_node("Container").set_theme(theme)
	dialogue_preview.get_node("Container/VBoxContainer/ThemeLabel").text = path.get_file()


func _on_remove_theme_pressed():
	dialogue_preview.get_node("Container").theme = null
	dialogue_preview.get_node("Container/VBoxContainer/ThemeLabel").text = "[default_theme]"
