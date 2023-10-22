class_name ItemOption extends OptionBase


signal item_selected;


@onready var Icon : TextureRect = $Layout/Container/TextureRect;
@onready var NameLabel := $Layout/Container/Name;
@onready var QuantityLabel := $Layout/Container/Quantity;

@export var item : ItemDefinition:
	set(itm):
		item = itm;
	get:
		return item;


func _ready():
	super._ready();


func _selected():
	super._selected();
	item_selected.emit(self);
	return null; # TODO: implement


func _on_menu_closed():
	super._on_menu_closed();
	print_debug("closing '%s'" % [name]);
