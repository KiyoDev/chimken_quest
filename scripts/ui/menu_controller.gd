class_name MenuController extends Node


@onready var Cursor : Cursor = preload("res://scenes/ui/cursor.tscn").instantiate();

@onready var Menu := $Menu;

var menu_stack := [];

var curr_menu : BaseMenu;


func _ready():
	add_child(Cursor);
	Cursor.visible = false;


func _input(event):
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right") ||
	   event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		Menu._navigate(Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down"));
		
#		Cursor.position = Vector2(focused_ele.global_position.x - 12, focused_ele.global_position.y + (focused_ele.size.y / 2));
#		Cursor._menu();
	elif(event.is_action_pressed(&"ui_accept")):
		var next_element = Menu._select();
		if(next_element is BaseMenu):
			menu_stack.push_back(curr_menu);
			curr_menu = next_element;
			curr_menu._open();
	elif(event.is_action_pressed(&"ui_cancel")):
		Menu._cancel();
		if(!menu_stack.is_empty()):
			curr_menu._cancel();
			curr_menu = menu_stack.pop_back();


func open():
	Menu._open();
	if(!Cursor.visible): Cursor.visible = true;
	Cursor._menu();
