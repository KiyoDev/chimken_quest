class_name Cursor extends Node2D


signal focus_changed;
signal menu_closed;


@onready var Sprite = $Sprite2D;
@onready var Animator = $AnimationPlayer;


var menu_stack := [];

var menu_open := false;
var curr_menu : Menu;
var focused_opt : OptionBase;


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Animator - %s" % [Animator]);
	hide();


#func test(event : InputEvent):
#	if(event is InputEventKey):
#		if((event as InputEventKey).keycode == KEY_O):
#			print("MenuController - O");
#			if(!menu_open):
#	#			Menu = BattleMenu;
##				remove_child(get_node("Menu"));
##				add_child(BattleMenu);
##				curr_menu = BattleMenu;
#	#			print("ctrl - Menu %s" % [get_node("Menu")]);
#				print("curr_menu %s" % [curr_menu]);
##				open();
#		elif((event as InputEventKey).keycode == KEY_Q):
#			if(menu_open):
#				print("force exit menu");
##				close();
#	pass;


func _input(event):
	if(!menu_open): return; # do nothing if menu isn't open
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right") ||
	   event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		var direction := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down");
		navigate_manu(direction.sign());
	elif(event.is_action_pressed(&"ui_accept")):
		var next_option = curr_menu._select_option();
		print("accept option - '%s'" % [next_option]);
		
		if(next_option == null): return;
		
#		change_focus(next_option);
	elif(event.is_action_pressed(&"ui_cancel")):
		print("cancel on '%s'" % [curr_menu]);
		cancel_option();


func navigate_manu(direction):
	var option = curr_menu._navigate(direction);
	if(option == null || option == focused_opt): 
		return;
	change_focus(option);

#	add_child(Cursor);
#	Cursor.show();
#	Cursor._menu();
#	Cursor._on_navigate(focused_opt); # TODO: maybe instead of moving a cursor, could have animated cursor on each element that changes from selected/unselected, etc...
#	menu_opened.emit();


func change_focus(next):
	if(next == null): return;
	if(focused_opt != null): 
		focused_opt._unfocus(); # unfocus previous option
		
	focused_opt = next;
	focused_opt._focus(); # focus new option
	focus_changed.emit(focused_opt);
	update_pos(focused_opt);


func update_pos(option : OptionBase):
#	print("updating cursor pos - [%s, %s]" % [global_position, option.global_position]);
	global_position = Vector2(option.global_position.x - 4, option.global_position.y + (option.size.y / 2));
	

func open(menu):
	menu_open = true;
	curr_menu = menu;
	_menu();
	curr_menu.connect_cursor_to_menu(self);
	var next = curr_menu._open();
	on_menu_open(next);
	show();
		

func close():
	menu_open = false;
	curr_menu._exit();
	while(!menu_stack.is_empty()):
		menu_stack.pop_back()._exit();
	hide();
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


func _menu():
#	print("menu - %s" % [Animator]);
	Animator.play(&"menu_cursor");
	

func _target_selected():
	Animator.play(&"target_cursor_selected");
	

func _target_unselected():
	Animator.play(&"target_cursor_unselected");
