class_name ActionOption extends OptionBase


@onready var Background : Sprite2D = $Background; # background to show when option is selected
@onready var Sprite : Sprite2D = $Sprite2D;
@onready var NameLabel := $Name;
@onready var CostLabel := $Cost;
@onready var CursorPosition := $CursorPosition;

@export var action : ActionDefinition:
	set(act):
		action = act;
	get:
		return action;


func _ready():
	super._ready();


func _cursor_position():
	return CursorPosition.position;


func _cursor_global_position():
	print("Background %s" % [Background]);
	print("NameLabel %s" % [NameLabel]);
	print("CostLabel %s" % [CostLabel]);
	print("CursorPosition %s" % [CursorPosition]);
	return CursorPosition.global_position;


func _selected():
	pass;
