@tool
class_name OfferingElement extends VBoxContainer


signal delete_pressed(offering : OfferingElement);


@export var ItemName : LineEdit;
@export var ItemType : LineEdit;
@export var Quantity : SpinBox;


func _ready():
	pass;


func _on_delete_pressed():
	delete_pressed.emit(self);
