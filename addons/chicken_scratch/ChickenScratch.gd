@tool
class_name ChickenScratchPlugin extends EditorPlugin

const DIALOGUE_ACCEPT := "input/dialogue_accept"
const DIALOGUE_CANCEL := "input/dialogue_cancel"
const ACCEPT_SETTING_OVERRIDE := "dialogue/settings/accept"
const CANCEL_SETTING_OVERRIDE := "dialogue/settings/cancel"
const GRAPH = preload("res://addons/chicken_scratch/graph/dialogue_graph.tscn")

var graph_instance : DialogueGraphEditor

#func _ready():
#	print_debug(graph)

var enabled : bool


func _enter_tree():
	print_debug(get_editor_interface().get_editor_main_screen().get_children())
	
	graph_instance = GRAPH.instantiate()
	# Initialization of the plugin goes here.

	get_editor_interface().get_editor_main_screen().add_child(graph_instance)
	_make_visible(false)


func _ready():
	print_debug("graph - %s, %s" % [graph_instance, graph_instance.has_method("on_plugin_start")])
	graph_instance.on_plugin_start()


func _exit_tree():
	_make_visible(false)
	if(enabled && graph_instance):
#		print_debug("exit tree")
		graph_instance.release_focus()
		get_editor_interface().get_editor_main_screen().remove_child(graph_instance)
		graph_instance.queue_free()
#		get_editor_interface().get_editor_main_screen().get_
#		get_editor_interface().get_editor_main_screen().get_child(0).grab_focus()
#		get_editor_interface().get_editor_main_screen().get_child(0).visible = true
#		update_overlays()


func _enable_plugin():
	print("enable")
	add_autoload_singleton("ChickenScratch", "res://addons/chicken_scratch/core/DialogueManager.gd")
	default_settings()
	enabled = true
	

func _disable_plugin():
	remove_autoload_singleton("ChickenScratch")
	enabled = false
#	if(graph_instance):
##		print_debug("disable plugin, %s" % [_get_plugin_name()])
##		print_debug("disable plugin, %s" % [get_editor_interface().get_editor_main_screen().get_child(0)])
##		var curr := get_viewport().gui_get_focus_owner()
###		curr.visible = false
##		curr.release_focus()
#
#		graph_instance.release_focus()
##		get_editor_interface().get_editor_main_screen().remove_child(graph_instance)
#		graph_instance.queue_free()
##		get_editor_interface().get_editor_main_screen().get_child(0).grab_focus()
##		get_editor_interface().get_editor_main_screen().get_child(0).visible = true
##		update_overlays()


func _has_main_screen():
	return true


func _make_visible(visible):
	if graph_instance:
		graph_instance.visible = visible


func _get_plugin_name():
	return "Chicken Scratch"


func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")


func default_settings():
	if(!ProjectSettings.has_setting(DIALOGUE_ACCEPT)):
		var enter := InputEventKey.new()
		enter.keycode = KEY_ENTER
		var space := InputEventKey.new()
		space.keycode = KEY_SPACE
		var x := InputEventKey.new()
		x.keycode = KEY_X
		var controller_input := InputEventJoypadButton.new()
		controller_input.button_index = JOY_BUTTON_A
		
		ProjectSettings.set_setting(DIALOGUE_ACCEPT, {
			'events': [
				enter,
				space,
				x,
				controller_input
			]
		});
		ProjectSettings.save()
		
	if(!ProjectSettings.has_setting(DIALOGUE_CANCEL)):
		var escape := InputEventKey.new()
		escape.keycode = KEY_ESCAPE
		var backspace := InputEventKey.new()
		backspace.keycode = KEY_BACKSPACE
		var z := InputEventKey.new()
		z.keycode = KEY_Z
		var controller_input := InputEventJoypadButton.new()
		controller_input.button_index = JOY_BUTTON_B
		
		ProjectSettings.set_setting(DIALOGUE_CANCEL, {
			'events': [
				escape,
				backspace,
				z,
				controller_input
			]
		});
		ProjectSettings.save()

