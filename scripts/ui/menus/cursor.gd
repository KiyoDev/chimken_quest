class_name Cursor extends Node2D


signal focus_changed;
signal option_selected;
signal menu_closed;


enum Direction {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT
}


@onready var Sprite = $Sprite2D;
@onready var Animator = $AnimationPlayer;


var menu_stack := [];

var menu_open := false;
var curr_menu : Menu;
var focused_opt : OptionBase;

# TODO: move focus indices here for menus?

# Called when the node enters the scene tree for the first time.
func _ready():
#	print("Animator - %s" % [Animator]);
	hide();


func horizontal(event) -> bool:
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right")):
		return true;
	elif(event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		return false
	return false;
	

func _input(event):
	if(!menu_open): return; # do nothing if menu isn't open
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right") ||
	   event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		var move := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down");
		var horizontal := horizontal(event);
		navigate_manu(move.sign(), horizontal);
	elif(event.is_action_pressed(&"ui_accept")):
		var next_option = curr_menu._select_option();
		print("accept option - '%s'" % [next_option]);
		
		if(next_option == null): return;
		
		change_focus(next_option);
	elif(event.is_action_pressed(&"ui_cancel")):
		print("cancel on '%s'" % [curr_menu]);
		cancel_option();


func navigate_manu(move, horizontal):
	var option = curr_menu._navigate(move, horizontal);
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
	update_pos(focused_opt);


func update_pos(option : OptionBase):
#	print("updating cursor pos - [%s, %s]" % [global_position, option.global_position]);
	global_position = Vector2(option.global_position.x - 5, option.global_position.y + (option.size.y / 2));
	

func open(menu):
	if(menu_open): return;
	
	menu_open = true;
	curr_menu = menu;
	_menu();
	curr_menu._connect_option_selected(on_option_selected);
#	curr_menu.connect_cursor_to_menu(self);
#	for opt in curr_menu.Options.get_children():
#		pass;
	var next = curr_menu._open();
	on_menu_open(next);
	show();
		

func close():
	if(!menu_open): return;
	
	menu_open = false;
	curr_menu._disconnect_option_selected(on_option_selected);
#	curr_menu._exit();
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


func _menu():
#	print("menu - %s" % [Animator]);
	Animator.play(&"menu_cursor");


# Signal functions

func on_option_selected(option : OptionBase, menu : Menu):
	print("cursor_on_option_selected[%s]" % [option]);
	if(option is SubmenuOption || option is SeparatedSubmenuOption):
		print("menu[%s] selected" % [option]);
		menu_stack.push_back(curr_menu);
		curr_menu = option.Menu;
		var next = curr_menu._get_current_option();
		on_menu_open(next);


#func on_menu_selected(menu):
#	print("menu[%s] selected" % [menu]);
#	menu_stack.push_back(curr_menu);
#	curr_menu = menu;
#	var next = curr_menu._get_current_option();
#	on_menu_open(next);


#func _target_selected():
#	Animator.play(&"target_cursor_selected");
#
#
#func _target_unselected():
#	Animator.play(&"target_cursor_unselected");
