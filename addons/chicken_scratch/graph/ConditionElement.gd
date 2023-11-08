@tool
class_name ConditionElement extends HBoxContainer


signal delete_requested(condition : ConditionElement);


@export var delete_button : Button;
@export var condition : LineEdit;


func get_condition() -> String:
	return condition.text;


func _on_delete_pressed():
	delete_requested.emit(self);
