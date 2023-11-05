@tool
class_name ResponseElement extends VBoxContainer


signal delete_pressed(node : Node);


@export var delete_button : Button;
@export var Text : TextEdit;


func text() -> String:
	return Text.text;


func set_text(text : String):
	Text.text = text;


func _on_delete_pressed():
	delete_pressed.emit(self);
