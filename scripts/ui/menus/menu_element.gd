class_name MenuBase extends ElementBase


signal menu_selected;

@onready var MenuController := %MenuController;

@onready var Sprite := $Sprite2D


@export var menu : BaseMenu;
# reference to menu scene


func _ready():
	menu_selected.connect(MenuController.on_menu_selected);


func _cursor_position(element):
	pass;


func _on_select():
	menu_selected.emit(menu);
	pass;
