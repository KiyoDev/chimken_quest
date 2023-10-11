class_name ActionOption extends OptionBase


@onready var Sprite : Sprite2D = $Sprite2D;
@onready var NameLabel := $Label;

@export var action : ActionDefinition:
	set(act):
		action = act;
	get:
		return action;


func _ready():
	pass # Replace with function body.


func _cursor_position():
	pass;


func _select():
	pass;
