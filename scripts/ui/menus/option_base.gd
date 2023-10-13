class_name OptionBase extends MarginContainer
# Interface for menu children; 


@onready var Background : NinePatchRect = $OptionBackground; # background to show when option is selected
@onready var Animator := $AnimationPlayer;


@export var selectable := true;


func _ready():
	Animator.play(&"unfocused");
	# ./Menu/Options/<option_base>
#	var parent_menu = get_parent().get_parent().get_parent().get_parent();
#	print(parent_menu.name);
#	print(parent_menu is Menu);
#	print(parent_menu.has_signal("menu_closed"));
#	print("%s - ...%s, %s, %s, %s" % [name, get_parent(), get_parent().get_parent(), get_parent().get_parent().get_parent(), get_parent().get_parent().get_parent().get_parent()])
#	parent_menu.ping();
	pass;


func _selected():
	pass;


func _focus():
	if(selectable):
		Animator.play(&"focused_selectable") 
	else:
		Animator.play(&"focused_unselectable");


func _unfocus():
	Animator.play(&"unfocused");


func _on_menu_closed():
	print("Parent menu closed");
	_unfocus();
#	hide();
