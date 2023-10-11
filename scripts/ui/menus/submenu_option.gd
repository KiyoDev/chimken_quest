class_name SubmenuOption extends OptionBase
# MenuController element that contains a label, sprite, and a submenu

signal menu_selected;

@onready var Background : Sprite2D = $Background; # background to show when option is selected
@onready var NameLabel := $Label;
@onready var Menu := $Menu;
@onready var CursorPosition := $CursorPosition;

# reference to Menu scene / or use $Menu? 

@export var focused_background : Sprite2D;
@export var unfocused_background : Sprite2D;


func _ready():
	menu_selected.connect(MenuController.on_menu_selected);
	MenuController.menu_closed.connect(_on_menu_closed);
	Background = unfocused_background;
#	print("CursorPosition %s" % [CursorPosition]);


func _cursor_position():
	return CursorPosition.position;


func _cursor_global_position():
	print("Background %s" % [Background]);
	print("NameLabel %s" % [NameLabel]);
	print("Menu %s" % [Menu]);
	print("CursorPosition %s" % [CursorPosition]);
	return CursorPosition.global_position;


func _select():
	menu_selected.emit(Menu);


func _focus():
	Background = focused_background;


func _unfocus():
	Background = unfocused_background;


func _on_menu_opened():
	pass;


func _on_menu_closed():
	pass;
