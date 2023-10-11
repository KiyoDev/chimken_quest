class_name SubmenuOption extends OptionBase
# MenuController element that contains a label, sprite, and a submenu

signal menu_selected;

@onready var Background : Sprite2D = $Background; # background to show when option is selected
@onready var NameLabel := $Label;
@onready var menu := $Menu;

# reference to menu scene / or use $Menu? 

@export var focused_background : Sprite2D;
@export var unfocused_background : Sprite2D;


func _ready():
	menu_selected.connect(MenuController.on_menu_selected);
	MenuController.menu_closed.connect(_on_menu_closed());
	Background = unfocused_background;


func _cursor_position():
#	Sprite.position
	pass;


func _select():
	menu_selected.emit(menu);


func _focus():
	Background = focused_background;


func _unfocus():
	Background = unfocused_background;


func _on_menu_opened():
	pass;


func _on_menu_closed():
	pass;
