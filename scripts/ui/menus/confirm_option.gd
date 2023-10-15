class_name ConfirmOption extends OptionBase


signal option_confirmed;


#@onready var Sprite : Sprite2D = $Sprite2D;
@onready var NameLabel := $Layout/Container/Name;

@export var accept := true;


func _ready():
	super._ready();


func _selected():
	super._selected();
	option_confirmed.emit(accept);
	return null; # TODO: implement


func _focus():
	if(selectable):
		Animator.play(&"focused_selectable") 
	else:
		Animator.play(&"focused_unselectable");


func _unfocus():
	Animator.play(&"unfocused");


func _on_menu_closed():
	super._on_menu_closed();
	print("closing '%s'" % [name]);
