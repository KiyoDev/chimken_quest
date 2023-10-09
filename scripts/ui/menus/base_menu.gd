class_name BaseMenu extends Node2D


# v menu, h menu, grid menu

var is_focused := false;


func _navigate(direction):
	pass;


func _on_focus():
	is_focused = true;
	visible = true;


func _on_unfocus():
	is_focused = false;
	visible = false;


func _open():
	visible = true;


func _select():
	pass;


func _cancel():
	visible = false;
