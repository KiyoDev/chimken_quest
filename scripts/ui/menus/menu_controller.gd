extends Node

# Menu controller
#	- Menu
#		- Menu items (other menus or options)
#

signal menu_opened;
signal menu_closed;

@onready var Cursor : Cursor = $Cursor;
@onready var Menu := $Menu;

var menu_stack := [];

var menu_open := false;
var curr_menu : BaseMenu;
var focused_ele;


func _ready():
	add_child(Cursor);
	Cursor.visible = false;
	curr_menu = Menu;


func _input(event):
	if(!menu_open): return; # do nothing if menu isn't open
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right") ||
	   event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		var next = curr_menu._navigate(Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down"));
		
		if(next == focused_ele): return;
		
		focused_ele = next;
		Cursor._on_navigate(focused_ele);
#		Cursor.position = Vector2(focused_ele.global_position.x - 12, focused_ele.global_position.y + (focused_ele.size.y / 2));
#		Cursor._menu();
	elif(event.is_action_pressed(&"ui_accept")):
		var next_element = curr_menu._select();
		if(next_element is MenuElement):
			menu_stack.push_back(curr_menu);
			curr_menu = next_element.menu;
			curr_menu._open();
	elif(event.is_action_pressed(&"ui_cancel")):
		curr_menu._cancel();
		if(!menu_stack.is_empty()):
			curr_menu._cancel();
			curr_menu = menu_stack.pop_back();


func open():
	curr_menu._open();
	if(!Cursor.visible): Cursor.visible = true;
	Cursor._menu();
	menu_open = true;
	menu_opened.emit();


func close():
	curr_menu._cancel();
	Cursor.visible = false;
	menu_open = false;
	menu_closed.emit();


func swap_menu(new_menu):
	Menu = new_menu;


func on_menu_selected(menu):
	menu_stack.push_back(curr_menu);
