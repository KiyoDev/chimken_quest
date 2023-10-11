extends Node

# Menu controller
#	- Menu
#		- Menu items (other menus or options)
#

signal menu_opened;
signal menu_closed;
signal focus_changed;


@onready var Cursor : Cursor = $Cursor as Cursor;
#@onready var Menu : MenuBase = $Menu as MenuBase;

var menu_stack := [];

var menu_open := false;
var curr_menu : MenuBase;
var focused_opt : OptionBase;


func _ready():
	add_child(Cursor);
	Cursor.visible = false;
#	curr_menu = Menu;
#	print("ctrl - Menu %s" % [Menu]);
	print("ctrl - BattleMenu %s" % [BattleMenu]);


@onready var BattleMenu := preload("res://scenes/ui/battle_menu.tscn").instantiate();

func test(event : InputEvent):
	if(event is InputEventKey):
		if((event as InputEventKey).keycode == KEY_O):
			print("MenuController - O");
			if(!menu_open):
	#			Menu = BattleMenu;
				remove_child(get_node("Menu"));
				add_child(BattleMenu);
				curr_menu = BattleMenu;
	#			print("ctrl - Menu %s" % [get_node("Menu")]);
				print("curr_menu %s" % [curr_menu]);
				open();
		elif((event as InputEventKey).keycode == KEY_Q):
			if(menu_open):
				print("force exit menu");
				close();
	pass;


func _input(event):
	test(event);
	
	if(!menu_open): return; # do nothing if menu isn't open
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right") ||
	   event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		var next_option = curr_menu._navigate(Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down"));
		
		if(next_option == null || next_option == focused_opt): return;
		
		change_focus(next_option);
	elif(event.is_action_pressed(&"ui_accept")):
		var next_option = curr_menu._select_option();
		print("accept option - '%s'" % [next_option]);
		
		if(next_option == null): return;
		
#		next_option._selected(); # TODO: i believe this can be called from the menu itself
		change_focus(next_option);
	elif(event.is_action_pressed(&"ui_cancel")):
		print("cancel on '%s'" % [curr_menu]);
		if(!menu_stack.is_empty()):
			print("!menu_stack.is_empty() '%s'" % [curr_menu]);
			curr_menu._cancel();
			curr_menu = menu_stack.pop_back();
			curr_menu._focus();
			print("after - '%s'" % [curr_menu]);
			change_focus(curr_menu._get_current_option());
		else:
			curr_menu._try_exit(); # Try to exit menu if escapeable


func change_focus(next):
	if(focused_opt != null): 
		focused_opt._unfocus(); # unfocus previous option
		
	focused_opt = next;
	focused_opt._focus(); # focus new option
	Cursor._on_navigate(focused_opt);
	focus_changed.emit(focused_opt);


func open():
	menu_open = true;
	curr_menu._open();
	if(!Cursor.visible): Cursor.visible = true;
	add_child(Cursor);
	focused_opt = curr_menu.get_child(0);
	Cursor._menu();
	Cursor._on_navigate(focused_opt); # TODO: maybe instead of moving a cursor, could have animated cursor on each element that changes from selected/unselected, etc...
	menu_opened.emit();


func close():
	curr_menu._exit();
	while(!menu_stack.is_empty()):
		menu_stack.pop_back()._exit();
	Cursor.visible = false;
	menu_open = false;
	menu_closed.emit();


func swap_menu(new_menu):
#	Menu = new_menu;
	pass;

# Signal functions

#func on_option_selected(option):
#	pass;


func on_menu_selected(menu):
	print("menu[%s] selected" % [menu]);
	menu_stack.push_back(curr_menu);
	curr_menu = menu;
#	change_focus(curr_menu._open());
	
