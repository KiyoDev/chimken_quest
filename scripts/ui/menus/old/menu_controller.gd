class_name MenuController extends Node


signal menu_opened;
signal menu_closed;
signal focus_changed;


@onready var Cursor : Cursor = preload("res://scenes/ui/cursor.tscn").instantiate();
#@onready var Cursor : Cursor = $Cursor as Cursor;
#@onready var Menu : MenuBase = $Menu as MenuBase;

var menu_stack := [];

var menu_open := false;
var curr_menu : MenuBase;
var focused_opt : OptionBase;


func _ready():
	pass;


func navigate_manu(direction):
	var option = curr_menu._navigate(direction);
	if(option == null || option == focused_opt): 
		return;
	change_focus(option);



func change_focus(next):
	if(next == null): return;
	if(focused_opt != null): 
		focused_opt._unfocus(); # unfocus previous option
		
	focused_opt = next;
	focused_opt._focus(); # focus new option
	focus_changed.emit(focused_opt);


func open(menu):
	menu_open = true;
	curr_menu = menu;
	Cursor._menu();
	curr_menu.connect_cursor_to_menu(self);
	var next = curr_menu._open();
	on_menu_open(next);
	Cursor.show();
		

func close():
	menu_open = false;
	curr_menu._exit();
	while(!menu_stack.is_empty()):
		menu_stack.pop_back()._exit();
	Cursor.hide();
	menu_closed.emit();


func cancel_option():
	if(!menu_stack.is_empty()):
		print("!menu_stack.is_empty() '%s'" % [curr_menu]);
		curr_menu._cancel();
		curr_menu = menu_stack.pop_back();
		curr_menu._focus();
		var next = curr_menu._get_current_option();
		on_menu_open(next);
		print("after - '%s'" % [curr_menu]);
#		change_focus(curr_menu._get_current_option());
	else:
		curr_menu._try_exit(); # Try to exit menu if escapeable
		

func on_menu_open(next):
	await get_tree().create_timer(0.001).timeout
	change_focus(next);

# Signal functions


func on_menu_selected(menu):
	print("menu[%s] selected" % [menu]);
	menu_stack.push_back(curr_menu);
	curr_menu = menu;
	var next = curr_menu._get_current_option();
	on_menu_open(next);
