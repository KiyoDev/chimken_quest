@tool
extends EditorPlugin


const graph = preload("res://addons/chicken_scratch/graph/dialogue_graph.tscn");

var graph_instance : DialogueGraphEditor;

#func _ready():
#	print_debug(graph);

var enabled : bool;


func _enter_tree():
	graph_instance = graph.instantiate();
	# Initialization of the plugin goes here.
	print_debug(get_editor_interface().get_editor_main_screen().get_children());
#	print_debug(graph_instance);

	get_editor_interface().get_editor_main_screen().add_child(graph_instance);
	_make_visible(false);
	graph_instance.on_plugin_start();


func _exit_tree():
	_make_visible(false);
	if(enabled && graph_instance):
#		print_debug("exit tree");
		graph_instance.release_focus();
		get_editor_interface().get_editor_main_screen().remove_child(graph_instance);
		graph_instance.queue_free();
#		get_editor_interface().get_editor_main_screen().get_
#		get_editor_interface().get_editor_main_screen().get_child(0).grab_focus();
#		get_editor_interface().get_editor_main_screen().get_child(0).visible = true;
#		update_overlays();


func _enable_plugin():
	enabled = true;
	

func _disable_plugin():
	_make_visible(false);
	enabled = false;
	if(graph_instance):
		print_debug("disable plugin, %s" % [get_viewport().gui_get_focus_owner().name]);
#		print_debug("disable plugin, %s" % [get_editor_interface().get_editor_main_screen().get_child(0)]);
#		var curr := get_viewport().gui_get_focus_owner();
##		curr.visible = false;
#		curr.release_focus();
		
		graph_instance.release_focus();
		get_editor_interface().get_editor_main_screen().remove_child(graph_instance);
		graph_instance.queue_free();
#		get_editor_interface().get_editor_main_screen().get_child(0).grab_focus();
#		get_editor_interface().get_editor_main_screen().get_child(0).visible = true;
#		update_overlays();


func _has_main_screen():
	return true;


func _make_visible(visible):
	if graph_instance:
		graph_instance.visible = visible;


func _get_plugin_name():
	return "Chicken Scratch";


func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons");
