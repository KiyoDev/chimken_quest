@tool
class_name ResponseElement extends VBoxContainer


@onready var Text = $ScrollContainer/ResponseText;


func text() -> String:
	return Text.text;


func set_text(text : String):
	Text.text = text;
