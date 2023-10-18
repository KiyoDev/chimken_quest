class_name BattleMenuManager extends CanvasLayer


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


# FIXME: currently, menu is its own fully built scene; need to change attack and skill submenus to be populated by the current ally's actions; items and escape stay constant
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
	
#	print("atks - %s" % [attacks_menu]);
	


func setup_action_option(action : ActionDefinition) -> ActionOption:
	var option := ActionOptionTemplate.clone();
	print("\taction - %s" % [action]);
	option.hide();
#	container.add_child(option);
#	ActionHelper.add_child(option);
	option.name = action.name;
	option.NameLabel.text = action.name;
	option.CostLabel.text = str(action.cost) if action.cost > 0 else "";
	option._connect_option_selected(on_option_selected);
	return option;
	

func on_battle_started(allies : Array):
	print("Menu - %s" % [BattleMenu]);
	_open_menu();
	print("atks - %s" % [attacks_menu.get_options()]);


func on_battle_ended():
	_close_menu();
	Game.overworld();


func _open_menu():
	BattleMenu._connect_option_selected(on_option_selected);
	Cursor.open(BattleMenu);


func _close_menu():
	BattleMenu._disconnect_option_selected(on_option_selected);
	BattleMenu._exit();
	Cursor.close();


func swap_actions(character : Character):
	var name = character.info.character_name;
	
	var attacks : Array[ActionDefinition] = character.info.attacks;
	var skills : Array[ActionDefinition] = character.info.skills;
	
	print("swapping atks - %s, %s, %s" % [attacks_menu, attacks_menu.get_options(), skills_menu.get_options()]);
	
	swap(attacks, attacks_menu);
	swap(skills, skills_menu);

	adjust_options_count(attacks, attacks_menu);
	adjust_options_count(skills, skills_menu);
		
	print("swapped atks - %s\n\t> %s\n\t> %s" % [attacks_menu, attacks_menu.get_options(), skills_menu.get_options()]);


func swap(actions : Array[ActionDefinition], menu : Menu):
	for i in actions.size():
		var opt : ActionOption = menu.get_option(i);
		opt.swap_action(actions[i]);
		opt._show();

# FIXME: options aren't being hidden
func adjust_options_count(actions : Array[ActionDefinition], menu : Menu):
	if(menu.option_count() < actions.size()):
		for i in range(menu.option_count(), actions.size()):
			menu._add_option(ActionOptionTemplate.clone());
	elif(menu.option_count() > actions.size()):
		for i in range(actions.size(), menu.option_count()):
			menu.get_option(i)._hide();


# Signal Callables

## 
func on_option_selected(option : OptionBase, menu : Menu):
	print("on_option_selected - %s from %s" % [option, menu]);
	if(menu.name == "EscapeMenu"):
		if(option.accept):
			print("escape from battle");
			on_battle_ended();
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
