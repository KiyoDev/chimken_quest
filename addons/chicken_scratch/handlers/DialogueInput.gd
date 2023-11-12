class_name DialogueInputHandler extends Node


signal accept_input

signal cancel_input


var input_consumed := false;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func handle_accept():
	
#	print_debug("DialogueBox input - %s" % [event])
#	tween_finished = false
#	indicator_animator.stop()
#	indicator.hide()
#	go_next.emit(true)

	if !input_consumed:
		input_consumed = true

	accept_input.emit()


func handle_cancel():
	pass;


func _input(event):
	if (!event is InputEventKey): return
	if Input.is_action_pressed(ProjectSettings.get_setting(ChickenScratchPlugin.ACCEPT_SETTING_OVERRIDE, ChickenScratchPlugin.DIALOGUE_ACCEPT)):
		handle_accept()
	elif Input.is_action_pressed(ProjectSettings.get_setting(ChickenScratchPlugin.CANCEL_SETTING_OVERRIDE, ChickenScratchPlugin.DIALOGUE_CANCEL)):
		handle_cancel()

