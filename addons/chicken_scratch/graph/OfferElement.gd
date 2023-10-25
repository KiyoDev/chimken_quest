@tool
class_name OfferElement extends VBoxContainer


@onready var ItemName : LineEdit = $VBoxContainer/ItemName;
@onready var ItemType : LineEdit = $VBoxContainer/ItemType;
@onready var Quantity : SpinBox = $HBoxContainer/Quanitity;


func _ready():
	pass;
