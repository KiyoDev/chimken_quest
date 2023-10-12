class_name SubmenuOption extends OptionBase
# MenuController element that contains a label, sprite, and a submenu

signal menu_selected;

@onready var Background : NinePatchRect = $OptionBackground; # background to show when option is selected
@onready var NameLabel := $Label;
@onready var Menu := $Menu;
@onready var CursorPosition := $CursorPosition;
@onready var Animator := $AnimationPlayer;

# reference to Menu scene / or use $Menu? 

@export var focused_selectable : Sprite2D;
@export var focused_unselectable : Sprite2D;
@export var unfocused_selectable : Sprite2D;
@export var unfocused_unselectable : Sprite2D;


func _ready():
	super._ready();
	menu_selected.connect(MenuController.on_menu_selected);
	MenuController.menu_closed.connect(_on_menu_closed);
	Animator.play(&"unfocused");
#	Background.texture = unfocused_selectable.texture if selectable else unfocused_unselectable.texture;
#	print("CursorPosition %s" % [CursorPosition]);


func _cursor_position():
	return CursorPosition.position;


func _cursor_global_position():
	print("Background %s" % [Background]);
	print("NameLabel %s" % [NameLabel]);
	print("Menu %s" % [Menu]);
	print("CursorPosition %s" % [CursorPosition]);
	return CursorPosition.global_position;


func _selected():
#	show();
	menu_selected.emit(Menu);
	return Menu._open();


func _focus():
	if(selectable):
		Animator.play(&"focused_selectable") 
	else:
		Animator.play(&"focused_unselectable");


func _unfocus():
	Animator.play(&"unfocused");


func _on_menu_opened():
	pass;


func _on_menu_closed():
	pass;
