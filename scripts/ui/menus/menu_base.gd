class_name MenuBase extends Node2D


# v menu, h menu, grid menu

#signal option_selected;


var is_focused := false;


func _ready():
#	option_selected.connect(MenuController.on_option_selected);
	pass;


func _navigate(direction):
	pass;


func _show():
	visible = true;


func _hide():
	visible = false;


func _on_focus():
	is_focused = true;


func _on_unfocus():
	is_focused = false;


func _open():
	visible = true;


func _select_option():
	pass;


func _cancel():
	visible = false;
