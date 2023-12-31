@tool
class_name DialogueInputHandler extends Node


signal accept_input

signal cancel_input

signal input_action

signal input_up

signal input_down

signal accept_response


enum Focused {
	DIALOGUE_BOX,
	RESPONSE_BOX
}


const DIALOGUE_ACCEPT := "dialogue_accept"
const DIALOGUE_CANCEL := "dialogue_cancel"
const ACCEPT_SETTING_OVERRIDE := "dialogue/settings/accept"
const CANCEL_SETTING_OVERRIDE := "dialogue/settings/cancel"

var input_consumed := false;


static var focused := Focused.DIALOGUE_BOX


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func handle_accept_dialogue():
	print_debug("accepted")
	if(!input_consumed):
		input_consumed = true

	accept_input.emit()
	input_action.emit()


func handle_cancel_dialogue():
	print_debug("canceled")
	if(!input_consumed):
		input_consumed = true

	cancel_input.emit()
	input_action.emit()

# FIXME: when in dialogue node, need to change focus to response box if applicable to pull inputs away from the main dialogue box; this is to allow the response box to receive input instead
func _input(event):
#	print("inputtt - %s, %s, %s, %s" % [ChickenScratch.started, event is InputEventKey, event.is_action_pressed(DIALOGUE_ACCEPT) if event is InputEventKey else "not key", Input.is_key_pressed(KEY_SPACE)])
	if(!ChickenScratch.playing || event is InputEventMouseMotion || event is InputEventMouseButton): return
	print("ChickenScratch input - %s" % [focused])
#	print_debug("has[%s] - %s" % [InputMap.get_actions(), ProjectSettings.get_setting("input/ui_accept")])
#	print_debug("has[%s] - %s, %s" % [DIALOGUE_ACCEPT,  ProjectSettings.get_setting("input/ui_accept"), ProjectSettings.get_setting("input/dialogue_accept")]) 
	if(focused == Focused.DIALOGUE_BOX && event is InputEventKey):
		var accept = ProjectSettings.get_setting(ACCEPT_SETTING_OVERRIDE, DIALOGUE_ACCEPT)
		var cancel = ProjectSettings.get_setting(CANCEL_SETTING_OVERRIDE, DIALOGUE_CANCEL)
	#	print("-- %s-%s-%s" % [accept, Input.is_action_pressed(accept), Input.is_action_pressed(ProjectSettings.get_setting(CANCEL_SETTING_OVERRIDE, DIALOGUE_CANCEL))])
		if(Input.is_action_pressed(accept)):
			handle_accept_dialogue()
		elif(Input.is_action_pressed(cancel)):
			handle_cancel_dialogue()
	elif(focused == Focused.RESPONSE_BOX && (Input.is_action_just_pressed(&"ui_up") || Input.is_action_just_pressed(&"ui_down") || Input.is_action_just_pressed(&"ui_accept"))):
		
		print("event.is_action_pressed(&ui_up)=%s" % [event.is_action_pressed(&"ui_up")])
		if(event.is_action_pressed(&"ui_up")):
			print_debug("response box input - %s" % [event.is_action_pressed(&"ui_up")])
			input_up.emit()
		elif(event.is_action_pressed(&"ui_down")):
			input_down.emit()
		elif(event.is_action_pressed(&"ui_accept")):
			accept_response.emit()
			
