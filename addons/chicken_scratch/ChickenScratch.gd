@tool
extends EditorPlugin


const graph = preload("res://addons/chicken_scratch/graph/dialogue_graph.tscn");

var graph_instance;

#func _ready():
#	print_debug(graph);


func _enter_tree():
	graph_instance = graph.instantiate();
	# Initialization of the plugin goes here.
#	print_debug(get_editor_interface().get_editor_main_screen().get_children());
#	print_debug(graph_instance);

	get_editor_interface().get_editor_main_screen().add_child(graph_instance);
	_make_visible(false);

func _exit_tree():
#	remove_control_from_docks(graph);
	if(graph_instance):
		graph_instance.queue_free();
#	remove_control_from_container(CONTAINER_TOOLBAR, graph_instance);


func _has_main_screen():
	return true;


func _make_visible(visible):
	if graph_instance:
		graph_instance.visible = visible;


func _get_plugin_name():
	return "Chicken Scratch";


func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons");
