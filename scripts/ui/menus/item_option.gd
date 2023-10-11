class_name ItemOption extends OptionBase


@onready var Sprite : Sprite2D = $Sprite2D;
@onready var NameLabel := $Name;
@onready var QuantityLabel := $Quantity;

@export var item : ItemDefinition:
	set(itm):
		item = itm;
	get:
		return item;


func _ready():
	pass # Replace with function body.


func _cursor_position():
	pass;


func _select():
	pass;
