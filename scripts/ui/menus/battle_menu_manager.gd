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


func on_battle_started(allies : Array):
	print("Menu - %s" % [BattleMenu]);
	_open_menu();
	print("atks - %s" % [attacks_menu.get_options()]);


func on_battle_ended():
	_close_menu();


func _open_menu():
	BattleMenu._connect_option_selected(on_option_selected);
	Cursor.open(BattleMenu);


func _show_menu():
	BattleMenu._show();
	Cursor._show();


func _hide_menu():
	BattleMenu._hide();
	Cursor._hide();


func _close_menu():
	BattleMenu._disconnect_option_selected(on_option_selected);
	BattleMenu._exit();
	Cursor.close();


func _reset():
	BattleMenu._reset();
	Cursor._reset();


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
		opt.swap_action(actions[i]);
		opt._show();


func adjust_menu_size(menu : Menu, size : int):
	if(menu.option_count() < size):
		for i in range(menu.option_count(), size):
			menu._add_option(ActionOptionTemplate.clone());
	elif(menu.option_count() > size):
		for i in range(size, menu.option_count()):
			menu.get_option(i)._hide();


# Signal Callables

## 
func on_option_selected(option : OptionBase, menu : Menu):
	print("on_option_selected - %s from %s" % [option, menu]);
	if(menu.name == "EscapeMenu"):
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
