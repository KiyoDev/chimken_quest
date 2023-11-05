@tool
class_name ResponseElement extends VBoxContainer


signal delete_requested(node : Node);


@export var delete_button : Button;
@export var Text : TextEdit;
@export var delete_confirmation : ConfirmationDialog;


func text() -> String:
	return Text.text;


func set_text(text : String):
	Text.text = text;


func _on_delete_pressed():
	delete_confirmation.show();


func _on_confirmation_dialog_confirmed():
	delete_requested.emit(self);


func _on_confirmation_dialog_canceled():
	pass # Replace with function body.
