@tool
class_name DialogueInputHandler extends Node


signal accept_input

signal cancel_input

signal input_action


const DIALOGUE_ACCEPT := "dialogue_accept"
const DIALOGUE_CANCEL := "dialogue_cancel"
const ACCEPT_SETTING_OVERRIDE := "dialogue/settings/accept"
const CANCEL_SETTING_OVERRIDE := "dialogue/settings/cancel"

var input_consumed := false;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func handle_accept():
	print_debug("accepted")
	if !input_consumed:
		input_consumed = true

	accept_input.emit()
	input_action.emit()


func handle_cancel():
	print_debug("canceled")
	if !input_consumed:
		input_consumed = true

	cancel_input.emit()
	input_action.emit()


func _input(event):
#	print("inputtt - %s, %s, %s, %s" % [ChickenScratch.started, event is InputEventKey, event.is_action_pressed(DIALOGUE_ACCEPT) if event is InputEventKey else "not key", Input.is_key_pressed(KEY_SPACE)])
	if(!ChickenScratch.started || !event is InputEventKey): return
#	print("INPUT")
#	if(Input.is_key_pressed(KEY_SPACE)):
#		handle_accept()   
#	print_debug("has[%s] - %s" % [InputMap.get_actions(), ProjectSettings.get_setting("input/ui_accept")])
#	print_debug("has[%s] - %s, %s" % [DIALOGUE_ACCEPT,  ProjectSettings.get_setting("input/ui_accept"), ProjectSettings.get_setting("input/dialogue_accept")]) 
	var accept = ProjectSettings.get_setting(ACCEPT_SETTING_OVERRIDE, DIALOGUE_ACCEPT)
#	print("-- %s-%s-%s" % [accept, Input.is_action_pressed(accept), Input.is_action_pressed(ProjectSettings.get_setting(CANCEL_SETTING_OVERRIDE, DIALOGUE_CANCEL))])
	if(Input.is_action_pressed(ProjectSettings.get_setting(ACCEPT_SETTING_OVERRIDE, DIALOGUE_ACCEPT))):
		handle_accept()
	elif(Input.is_action_pressed(ProjectSettings.get_setting(CANCEL_SETTING_OVERRIDE, DIALOGUE_CANCEL))):
		handle_cancel()
