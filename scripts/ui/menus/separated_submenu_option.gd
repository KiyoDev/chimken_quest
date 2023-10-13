class_name SeparatedSubmenuOption extends OptionBase
# MenuController element that contains a label, sprite, and a submenu

signal menu_selected;

@onready var NameLabel := $Layout/Container/Name;

# reference to Menu scene / or use $Menu? 

@export var focused_selectable : Sprite2D;
@export var focused_unselectable : Sprite2D;
@export var unfocused_selectable : Sprite2D;
@export var unfocused_unselectable : Sprite2D;
@export var Menu : Menu;


func _ready():
	super._ready();
#	menu_selected.connect(MenuController.on_menu_selected);
#	MenuController.menu_closed.connect(_on_menu_closed);
#	Background.texture = unfocused_selectable.texture if selectable else unfocused_unselectable.texture;
#	print("CursorPosition %s" % [CursorPosition]);


func connect_to_menu_selected(cursor : Cursor):
#	if(obj.has_method("on_menu_selected")):
#	if(obj.has_signal("menu_closed")):

	menu_selected.connect(cursor.on_menu_selected);
	cursor.menu_closed.connect(_on_menu_closed);
	Menu.connect_cursor_to_menu(cursor);


func _selected():
#	show();
	menu_selected.emit(Menu);
	return Menu._open();


func _focus():
	super._focus();


func _unfocus():
	super._unfocus();


func _on_menu_opened():
	pass;


func _on_menu_closed():
	super._on_menu_closed();
	print("closing '%s'" % [name]);
