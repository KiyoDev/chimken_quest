class_name SeparatedSubmenuOption extends OptionBase
# MenuController element that contains a label, sprite, and a submenu


@onready var NameLabel := $Layout/Container/Name;


@export var Menu : Menu;


func _ready():
	super._ready();
#	menu_selected.connect(MenuController.on_menu_selected);
#	MenuController.menu_closed.connect(_on_menu_closed);
#	Background.texture = unfocused_selectable.texture if selectable else unfocused_unselectable.texture;
#	print("CursorPosition %s" % [CursorPosition]);


## Connect callable to this option's option_selected signal, as well as the menu's options' signals;
func _connect_option_selected(callable):
	option_selected.connect(callable);
	Menu._connect_option_selected(callable);
	
	
func _disconnect_option_selected(callable):
	option_selected.disconnect(callable);
	Menu._disconnect_option_selected(callable);
	
	
func _selected():
	print("_selected sep submenu '%s'" % [name]);
	super._selected();
#	menu_selected.emit(Menu);
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
