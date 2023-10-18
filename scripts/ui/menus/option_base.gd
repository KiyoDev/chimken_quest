class_name OptionBase extends MarginContainer
# Interface for menu children; 


signal option_selected;


@onready var Background : NinePatchRect = $OptionBackground; # background to show when option is selected
@onready var Animator := $OptionBackground/AnimationPlayer;


@export var selectable := true;


func _ready():
	Animator.play(&"unfocused");
	Background.show();
	# ./Menu/Options/<option_base>
#	var parent_menu = get_parent().get_parent().get_parent().get_parent();
#	print(parent_menu.name);
#	print(parent_menu is Menu);
#	print(parent_menu.has_signal("menu_closed"));
#	print("%s - ...%s, %s, %s, %s" % [name, get_parent(), get_parent().get_parent(), get_parent().get_parent().get_parent(), get_parent().get_parent().get_parent().get_parent()])
	pass;


func parent_menu() -> Menu:
	return get_parent().get_parent().get_parent().get_parent();


func _selected():
	print("emit '%s'" % [option_selected]);
	option_selected.emit(self, parent_menu());


func _exit():
	pass;


func _reset():
	pass;


func _hide():
	pass;


func _focus():
	if(selectable):
		Animator.play(&"focused_selectable") 
	else:
		Animator.play(&"focused_unselectable");


func _unfocus():
	Animator.play(&"unfocused");


func _connect_option_selected(callable):
	option_selected.connect(callable);
	
	
func _disconnect_option_selected(callable):
	option_selected.disconnect(callable);


func _on_menu_closed():
	print("Parent menu closed");
	_unfocus();
#	hide();
