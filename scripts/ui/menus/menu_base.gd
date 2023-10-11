class_name MenuBase extends Node2D


# v menu, h menu, grid menu

signal menu_closed;


@export var escapeable := false;

var is_focused := false;


func _ready():
#	option_selected.connect(MenuController.on_option_selected);
	pass;


func _navigate(direction):
	pass;


func _focus():
	is_focused = true;


func _unfocus():
	is_focused = false;


func _show():
	show();


func _hide():
	hide();
	_unfocus();


## Opens the menu, showing and focusing
func _open():
	_show();


func _exit():
	print("Exiting MenuBase - '%s'" % [self]);
	_hide();
	menu_closed.emit();


func _try_exit():
	if(!escapeable): return;
	_hide();
	

func _select_option():
	pass;


func _get_current_option():
	pass;


func _cancel():
	_unfocus();
