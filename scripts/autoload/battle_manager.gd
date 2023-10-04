extends Node


@onready var BATTLE_UI = %BattleUI;
#@onready var ACTION_CATEGORIES = %BattleUI/StyleControl/ActionCategoriesPanel/ActionCategories;
#
#@onready var ATTACK_CATEGORY = %BattleUI/StyleControl/ActionCategoriesPanel/ActionCategories/Attacks;
#@onready var SKILL_CATEGORY = %BattleUI/StyleControl/ActionCategoriesPanel/ActionCategories/Skills;
#@onready var ITEM_CATEGORY = %BattleUI/StyleControl/ActionCategoriesPanel/ActionCategories/Items;
#@onready var ESCAPE_CATEGORY = %BattleUI/StyleControl/ActionCategoriesPanel/ActionCategories/Escape;
#
#@onready var ATTACK_LIST = %BattleUI/StyleControl/AttackListPanel/AttackList
## TODO: skills need to listen on character mana_updated signals; lets know if button should be disabled
#@onready var SKILL_LIST = %BattleUI/StyleControl/SkillListPanel/SkillList
#@onready var ITEM_LIST = %BattleUI/StyleControl/ItemListPanel/ItemList

@onready var ALLY_CONTAINER = $AllyContainer;
@onready var ENEMY_CONTAINER = $EnemyContainer;

@export var turn_queue : Array[Turn] = [];

@export var ally_turns : Array[AllyTurn] = []
@export var enemy_turns : Array[EnemyTurn] = []

@export var current_actor : Character;

static var round := 0;

## used to know which control element to go back to on cancel
## when focus switches to a sub menu, add current focused_ele to stack, then assign new focused
#var focus_stack : Array[Control]; 
#var focused_ele : Control;
#
#var menu_stack : Array[Control];
#var curr_menu : Control;
#
## ActionCategories -> Attacks, Skills, Items, Escape
##		bring up another window to show attacks, skills, items
## Called when the node enters the scene tree for the first time.
#func _ready():
##	print(skill_list.get_children()[0].get_children());
##	BATTLE_UI.visible = false;
#	get_viewport().connect(&"gui_focus_changed", _on_focus_changed);
#	(ACTION_CATEGORIES.get_child(0) as Control).grab_focus();
#	curr_menu = ACTION_CATEGORIES;
#	print(ACTION_CATEGORIES.get_children());
#	print()
#	pass # Replace with function body.
#
#
#func _on_focus_changed(control : Control):
#	print(control);
#	focused_ele = control;
#
#
#func _input(event):
#	if(focused_ele == null): return;
#
#	if(event.is_action_pressed(&"ui_select")):
#		# open menu corresponding to focused action category and change focus
#		print("Selected '%s'" % focused_ele);
#
#		if(focused_ele == ATTACK_CATEGORY):
#			menu_stack.push_back(curr_menu);
#			focus_stack.push_back(focused_ele);
#
#			curr_menu = ATTACK_LIST.get_parent();
#			focused_ele = ATTACK_LIST.get_child(0);
#
#			curr_menu.visible = true;
#			focused_ele.grab_focus();
#		elif(focused_ele == SKILL_CATEGORY):
#			menu_stack.push_back(curr_menu);
#			focus_stack.push_back(focused_ele);
#
#			curr_menu = SKILL_LIST.get_parent();
#			focused_ele = SKILL_LIST.get_child(0);
#
#			curr_menu.visible = true;
#			focused_ele.grab_focus();
#		elif(focused_ele == ITEM_CATEGORY):
#			menu_stack.push_back(curr_menu);
#			focus_stack.push_back(focused_ele);
#
#			curr_menu = ITEM_LIST.get_parent();
#			focused_ele = ITEM_LIST.get_child(0);
#
#			curr_menu.visible = true;
#			focused_ele.grab_focus();
#		elif(focused_ele == ESCAPE_CATEGORY):
#				pass;
#
#	elif(!menu_stack.is_empty() && event.is_action_pressed(&"ui_cancel")):
#		curr_menu.visible = false;
#		curr_menu = menu_stack.pop_back();
#		focused_ele = focus_stack.pop_back();
#		focused_ele.grab_focus();
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func init_battle(allies : Array[Character], enemy : Character):
	# init battle, calculate turn order, create turns
	# TODO: populate ally and enemy containers
	# TODO: populate lists of actions for each character that can swap out when turns change
	# TODO: instantiate enemies from a list based on the area
	round = 0;
	var enemy_list : Array[Character] = [enemy.duplicate(), enemy.duplicate()];
	
	for a in allies:
		ally_turns.append(AllyTurn.new(a));
	
	for e in enemy_list:
		enemy_turns.append(EnemyTurn.new(e));
	
	new_round();


func end_battle():
	
	pass 


func start_turn():
	current_actor = get_next_turn().character;
	# TODO: implement


func on_end_turn():
	pass;


func get_next_turn() -> Turn:
	if(turn_queue.is_empty()):
		new_round();
	
	return turn_queue.pop_front();


func new_round():
	turn_queue.append_array(ally_turns);
	turn_queue.append_array(enemy_turns);
	calc_turn_order();
	round += 1;


func calc_turn_order():
	turn_queue.sort_custom(func(a : Turn, b : Turn): return a.character.info.speed > b.character.info.speed);


func _on_attacks_focus_entered():
	print("focus on attacks category");
	pass # Replace with function body.
