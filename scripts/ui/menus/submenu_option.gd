class_name SubmenuOption extends OptionBase
# MenuController element that contains a label, sprite, and a submenu


@onready var NameLabel := $Layout/Container/Name;
@onready var Menu := $Menu;


@export var focused_selectable : Sprite2D;
@export var focused_unselectable : Sprite2D;
@export var unfocused_selectable : Sprite2D;
@export var unfocused_unselectable : Sprite2D;


func _ready():
	super._ready();


func _connect_option_selected(callable):
	option_selected.connect(callable);
	Menu._connect_option_selected(callable);
	Menu._unfocus();
	
	
func _disconnect_option_selected(callable):
	option_selected.disconnect(callable);
	Menu._disconnect_option_selected(callable);
	

func _selected():
	print_debug("_selected submenu '%s'" % [name]);
	super._selected();
	return Menu._open();


func _exit():
	Menu._exit();


func _reset():
	Menu._hide();
	Menu._reset();


func _hide():
	Menu._hide();


func _focus():
	super._focus();


func _unfocus():
	super._unfocus();


func _on_menu_opened():
	pass;


func _on_menu_closed():
	super._on_menu_closed();
	Menu._exit();
	print_debug("closing '%s'" % [name]);
