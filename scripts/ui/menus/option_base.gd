class_name OptionBase extends Node2D
# Interface for menu children; 


func _ready():
	get_parent().menu_closed.connect(on_menu_closed);


## Return designated cursor position
func _cursor_position():
	pass;


func _cursor_global_position():
	pass;


func _selected():
	pass;


func _focus():
	pass;


func _unfocus():
	pass;


func on_menu_closed():
	print("Parent menu closed");
