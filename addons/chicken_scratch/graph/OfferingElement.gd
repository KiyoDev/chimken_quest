@tool
class_name OfferingElement extends VBoxContainer


signal delete_requested(offering : OfferingElement);


@export var ItemName : LineEdit;
@export var ItemType : LineEdit;
@export var Quantity : SpinBox;
@export var delete_confirmation : ConfirmationDialog;


func _ready():
	pass;


func _on_delete_pressed():
	delete_confirmation.show();


func _on_confirmation_dialog_confirmed():
	delete_requested.emit(self);


func _on_confirmation_dialog_canceled():
	pass # Replace with function body.
