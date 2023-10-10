class_name MenuElement extends ElementBase


signal menu_selected;

@onready var Sprite : Sprite2D = $Sprite2D;
@onready var NameLabel := $Label;


@export var menu : BaseMenu;

# reference to menu scene / or use $Menu? 


func _ready():
	menu_selected.connect(MenuController.on_menu_selected);
	MenuController.menu_closed.connect(_on_menu_closed());


func _cursor_position():
#	Sprite.position
	pass;


func _on_select():
	menu_selected.emit(menu);


func _on_menu_opened():
	pass;


func _on_menu_closed():
	pass;
