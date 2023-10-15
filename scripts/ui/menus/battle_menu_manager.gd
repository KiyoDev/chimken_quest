class_name BattleMenuManager extends CanvasLayer


@onready var Cursor : Cursor = preload("res://scenes/ui/cursor.tscn").instantiate();
@onready var BattleMenuContainer := preload("res://scenes/ui/battle_menu.tscn").instantiate();
@onready var BattleMenu : Menu = BattleMenuContainer.get_node("%BattleMenu");
#@onready var LabelBackground = preload("res://scenes/ui/ui_menu_option_background.tscn").instantiate();

@onready var ActionOptionTemplate : ActionOption = preload("res://scenes/ui/menu_options/action_option_template.tscn").instantiate();

var character_actions := {};
# {"<name>": {"attacks": Array[ActionDefinition], "skills":  Array[ActionDefinition]} }

# FIXME: currently, menu is its own fully built scene; need to change attack and skill submenus to be populated by the current character's actions; items and escape stay constant
# how to display whether or not a skill can be used?
# need to have a signal for character mana changed for each option;

func _ready():
	show();
	add_child(BattleMenuContainer);
	add_child(Cursor);
	BattleSystem.battle_started.connect(on_battle_started);
	BattleSystem.battle_ended.connect(on_battle_ended);
	BattleMenuContainer.global_position = Vector2(100, 0);
	
# TODO: used for when using same menu and changing out the submenu options for actions
func init_labels(characters : Array[Character]):
	for character in characters:
		var char_name := character.info.character_name;
		character_actions[char_name] = {"attacks": [], "skills": []};
		
		for attack in character.info.attacks:
			var attack_option := setup_action_option(ActionOptionTemplate.duplicate(), attack);
			character_actions[char_name]["attacks"].push_back(attack_option);
		for skill in character.info.skills:
			var skill_option := setup_action_option(ActionOptionTemplate.duplicate(), skill);
			character_actions[char_name]["skills"].push_back(skill_option);
			


func setup_action_option(option : ActionOption, action : ActionDefinition) -> ActionOption:
	option.NameLabel.text = action.name;
	option.CostLabel.text = str(action.cost) if action.cost > 0 else "";
	return option;
	

func on_battle_started():
	print("Menu - %s" % [BattleMenu]);
	BattleMenu._connect_option_selected(on_option_selected);
	Cursor.open(BattleMenu);
	Game.battle();


func on_battle_ended():
	BattleMenu._disconnect_option_selected(on_option_selected);
	Cursor.close();
	Game.overworld();


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
