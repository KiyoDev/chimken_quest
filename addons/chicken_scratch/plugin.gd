@tool
class_name ChickenScratchPlugin extends EditorPlugin

const DIALOGUE_ACCEPT := "input/dialogue_accept"
const DIALOGUE_CANCEL := "input/dialogue_cancel"
const GRAPH = preload("res://addons/chicken_scratch/graph/dialogue_graph.tscn")

var graph_instance : DialogueGraphEditor

#func _ready():
#	print_debug(graph)

var enabled : bool


func _enter_tree():
	print_debug("_enter_tree")
	
	graph_instance = GRAPH.instantiate()
	graph_instance.hide()
	get_editor_interface().get_editor_main_screen().add_child(graph_instance)
	_make_visible(false)


func _exit_tree():
	_make_visible(false)
	if(enabled && graph_instance):
		remove_control_from_bottom_panel(graph_instance)
		graph_instance.queue_free()


func _ready():
	print_debug("_ready")


func _enable_plugin():
	print("_enable_plugin")
	default_settings()
	add_autoload_singleton("ChickenScratch", "res://addons/chicken_scratch/core/DialogueManager.gd")
	enabled = true
	graph_instance.on_plugin_start()
	

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
	print("has=%s, %s" % [ProjectSettings.has_setting(DIALOGUE_ACCEPT), InputMap.has_action("dialogue_accept")])
	var enter := InputEventKey.new()
	enter.keycode = KEY_ENTER
	var space := InputEventKey.new()
	space.keycode = KEY_SPACE
	var x := InputEventKey.new()
	x.keycode = KEY_X
	var controller_accept := InputEventJoypadButton.new()
	controller_accept.button_index = JOY_BUTTON_A
	
	if(!ProjectSettings.has_setting(DIALOGUE_ACCEPT)):

		ProjectSettings.set_setting(DIALOGUE_ACCEPT, {
			"deadzone": 0.5,
			"events": [
				enter,
				space,
				x,
				controller_accept
			]
		});

	if(!InputMap.has_action("dialogue_accept")):
		InputMap.add_action("dialogue_accept")
		InputMap.action_add_event("dialogue_accept", enter)
		InputMap.action_add_event("dialogue_accept", space)
		InputMap.action_add_event("dialogue_accept", x)
		InputMap.action_add_event("dialogue_accept", controller_accept)

	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	var backspace := InputEventKey.new()
	backspace.keycode = KEY_BACKSPACE
	var z := InputEventKey.new()
	z.keycode = KEY_Z
	var controller_cancel := InputEventJoypadButton.new()
	controller_cancel.button_index = JOY_BUTTON_B
	
	if(!ProjectSettings.has_setting(DIALOGUE_CANCEL)):

		ProjectSettings.set_setting(DIALOGUE_CANCEL, {
			"deadzone": 0.5,
			"events": [
				escape,
				backspace,
				z,
				controller_cancel
			]
		});

	if(!InputMap.has_action("dialogue_cancel")):
		InputMap.add_action("dialogue_cancel")
		InputMap.action_add_event("dialogue_cancel", escape)
		InputMap.action_add_event("dialogue_cancel", backspace)
		InputMap.action_add_event("dialogue_cancel", z)
		InputMap.action_add_event("dialogue_cancel", controller_cancel)
	ProjectSettings.save()

