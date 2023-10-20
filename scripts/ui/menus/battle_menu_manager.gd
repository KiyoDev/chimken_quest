class_name BattleMenuManager extends CanvasLayer


signal battle_escaped;


@onready var Cursor : Cursor = preload("res://scenes/ui/cursor.tscn").instantiate();
@onready var BattleMenuContainer := preload("res://scenes/ui/battle_menu.tscn").instantiate();
@onready var BattleMenu : Menu = BattleMenuContainer.get_node("%BattleMenu");
@onready var ActionHelper := BattleMenuContainer.get_node("ActionHelper");
#@onready var LabelBackground = preload("res://scenes/ui/ui_menu_option_background.tscn").instantiate();

@onready var ActionOptionTemplate : ActionOption = preload("res://scenes/ui/menu_options/action_option_template.tscn").instantiate();


# Cache submenus
var attacks_menu : Menu;
var skills_menu : Menu;
var items_menu : Menu;


var menu_stack : Array[Menu] = [];
var menu_open := false;
var curr_menu : Menu;

# TODO: populate items label values on battle start based off inventory; escape is constant
# how to display whether or not a skill can be used?
# need to have a signal for ally mana changed for each option;

func _ready():
	show();
	add_child(BattleMenuContainer);
	add_child(Cursor);
	BattleSystem.battle_started.connect(on_battle_started);
	BattleSystem.battle_ended.connect(on_battle_ended);
	BattleMenuContainer.global_position = Vector2(100, 0);
	
	attacks_menu = BattleMenuContainer.get_node("%AttacksMenu");
	skills_menu = BattleMenuContainer.get_node("%SkillsMenu");
	items_menu = BattleMenuContainer.get_node("%ItemsMenu");


func _input(event):
	if(!visible || !menu_open): return; # do nothing if menu isn't open or cursor visible
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right") ||
	   event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		var move := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down");
		var horizontal := horizontal(event);
		navigate_manu(move.sign(), horizontal);
	elif(event.is_action_pressed(&"ui_accept")):
		var next_option = curr_menu._select_option();
		print("accept option - '%s'" % [next_option]);
		
		if(next_option == null): return;
		
		Cursor.change_focus(next_option);
	elif(event.is_action_pressed(&"ui_cancel")):
		print("cancel on '%s'" % [curr_menu]);
		cancel_option();


func on_battle_started(allies : Array):
	print("Menu - %s" % [BattleMenu]);
	_open_menu();
	print("atks - %s" % [attacks_menu.get_options()]);


func on_battle_ended():
	_close_menu();


func _open_menu():
	if(menu_open): return;
	menu_open = true;
	
	BattleMenu._connect_option_selected(on_option_selected);
	curr_menu = BattleMenu;
#	curr_menu._connect_option_selected(on_option_selected);
	var next = curr_menu._open();
	Cursor.open(next);


func _close_menu():
	BattleMenu._disconnect_option_selected(on_option_selected);
	if(!menu_open): return;
	BattleMenu._exit();
	
	menu_open = false;
#	curr_menu._exit();
	while(!menu_stack.is_empty()):
		menu_stack.pop_back()._exit();
	Cursor.close();
	
	
func _show_menu():
	BattleMenu._show();
	Cursor._show();


func _hide_menu():
	BattleMenu._hide();
	Cursor._hide();


func _reset():
	BattleMenu._reset();
	if(menu_stack.size() > 0):
		curr_menu = menu_stack.pop_front();
		menu_stack.clear();
	Cursor._reset(curr_menu._get_current_option());
	curr_menu._focus();


func navigate_manu(move, horizontal):
	var option = curr_menu._navigate(move, horizontal);
	if(option == null || option == Cursor.focused_opt): 
		return;
	Cursor.change_focus(option);
	

func cancel_option():
	if(!menu_stack.is_empty()):
		print("!menu_stack.is_empty() '%s'" % [curr_menu]);
		curr_menu._cancel();
		curr_menu = menu_stack.pop_back();
		curr_menu._focus();
		curr_menu._show();
		var next = curr_menu._get_current_option();
		Cursor.on_menu_open(next);
		print("after - '%s'" % [curr_menu]);
#		change_focus(curr_menu._get_current_option());
	else:
		curr_menu._try_exit(); # Try to exit menu if escapeable


func horizontal(event) -> bool:
	if(event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right")):
		return true;
	elif(event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down")):
		return false
	return false;


func init_items_menu():
	# TODO: implement initialization
	# inventory.consumables
	# adjust_menu_size(items_menu, inventory.consumables.size());
	pass;


func swap_actions(character : Character):
	_reset();
	_show_menu();
	var name = character.info.character_name;
	
	var attacks : Array[ActionDefinition] = character.info.attacks;
	var skills : Array[ActionDefinition] = character.info.skills;

#	print("swapping atks - %s, %s, %s" % [attacks_menu, attacks_menu.get_options(), skills_menu.get_options()]);
	
	swap(attacks, attacks_menu);
	swap(skills, skills_menu);
		
#	print("swapped atks - %s\n\t> %s\n\t> %s" % [attacks_menu, attacks_menu.get_options(), skills_menu.get_options()]);


func swap(actions : Array[ActionDefinition], menu : Menu):
	adjust_menu_size(menu, actions.size());
	for i in actions.size():
		var opt : ActionOption = menu.get_option(i);
		print("swap - %s, %s" % [i, opt]);
		opt.swap_action(actions[i]);
		opt._show();

# FIXME: Options.get_child_count() doesn't take hidden children into acocunt, maybe do just remove excess labels during swap?
func adjust_menu_size(menu : Menu, size : int):
	if(menu.option_count() < size):
		for i in range(menu.option_count(), size):
			menu._add_option(ActionOptionTemplate.clone());
	elif(menu.option_count() > size):
		for i in range(menu.option_count() - 1, size - 1, -1): # remove options starting from the back
			menu._remove_option_by_index(i);
#		for i in range(size, menu.option_count()):
#			menu.get_option(i)._hide();


# Signal Callables

## 
func on_option_selected(option : OptionBase, menu : Menu):
	print("on_option_selected - %s from %s" % [option, menu]);
	
	if(option is SubmenuOption || option is SeparatedSubmenuOption):
		print("menu[%s] selected" % [option]);
		menu_stack.push_back(curr_menu);
		curr_menu = option.Menu;
		var next = curr_menu._get_current_option();
		Cursor.on_menu_open(next);
	elif(option is ActionOption):
		print("TODO: selected action - %s" % [option]);
	elif(menu.name == "EscapeMenu"):
		if(option.accept):
			print("escape from battle");
			on_battle_ended();
			battle_escaped.emit();
		else:
			print("cancelled escape");
			Cursor.cancel_option();


func on_action_selected(action_option : ActionOption):
	# -> choose a target; need to display targetable markers on targets
	pass;


func on_item_selected(item_option : ItemOption):
	pass;


func on_escape_confirmation(accepted : bool):
	pass;
