class_name ItemOption extends OptionBase


@onready var Background : NinePatchRect = $OptionBackground; #
@onready var Sprite : Sprite2D = $Sprite2D;
@onready var NameLabel := $Name;
@onready var QuantityLabel := $Quantity;
@onready var CursorPosition := $CursorPosition;

@export var item : ItemDefinition:
	set(itm):
		item = itm;
	get:
		return item;


func _ready():
	super._ready();


func _cursor_position():
	return CursorPosition.position;


func _cursor_global_position():
	return CursorPosition.global_position;
	

func _selected():
	pass;
