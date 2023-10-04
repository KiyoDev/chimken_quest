class_name BattleUI extends CanvasLayer


signal target_selected;


enum SelectState {
	Categories,
	Action,
	Target
}


@onready var ACTION_CATEGORIES : Node = %ActionCategories;
@onready var ATTACK_CATEGORY = %Attacks
@onready var SKILL_CATEGORY = %Skills;
@onready var ITEM_CATEGORY = %Items;
@onready var ESCAPE_CATEGORY = %Escape;

# TODO: attack and skill lists should have instances for each character
@onready var ATTACK_LIST = %AttackList;
# TODO: skills need to listen on character mana_updated signals; lets know if button should be disabled
@onready var SKILL_LIST = %SkillList;
@onready var ITEM_LIST = %ItemList;
@onready var ESCAPE_LIST = %EscapeList;

#@onready var ALLY_CONTAINER = $AllyContainer;
#@onready var ENEMY_CONTAINER = $EnemyContainer;

#@export var turn_queue : Array[Turn] = [] ;
#
#@export var ally_turns : Array[AllyTurn] = []
#@export var enemy_turns : Array[EnemyTurn] = []

@export var current_actor : Character;

static var round := 0;

# used to know which control element to go back to on cancel
# when focus switches to a sub menu, add current focused_ele to stack, then assign new focused
var state_stack : Array[SelectState];
var select_state : SelectState;

var focus_stack : Array[Control]; 
var focused_ele : Control;

var menu_stack : Array[Control];
var curr_menu : Control;

# ActionCategories -> Attacks, Skills, Items, Escape
#		bring up another window to show attacks, skills, items
# Called when the node enters the scene tree for the first time.
func _ready():
#	print(skill_list.get_children()[0].get_children());
#	BATTLE_UI.visible = false;
	print(ACTION_CATEGORIES);
	get_viewport().connect(&"gui_focus_changed", _on_focus_changed);
	(ACTION_CATEGORIES.get_child(0) as Control).grab_focus();
	curr_menu = ACTION_CATEGORIES;
	select_state = SelectState.Categories;


func _on_focus_changed(control : Control):
	print(control);
	focused_ele = control;


func _input(event):
	if(focused_ele == null): return;
	
	if(event.is_action_pressed(&"ui_select")):
		# open menu corresponding to focused action category and change focus
		match(select_state):
			SelectState.Categories:
				print("category - selected '%s'" % focused_ele);
				state_stack.push_back(select_state);
				select_category();
			SelectState.Action:
				print("action - selected '%s'" % focused_ele);
				if(select_state == SelectState.Action): return;
				state_stack.push_back(select_state);
			SelectState.Target:
				pass;
			
	elif(!menu_stack.is_empty() && event.is_action_pressed(&"ui_cancel")):
		curr_menu.visible = false;
		curr_menu = menu_stack.pop_back();
		focused_ele = focus_stack.pop_back();
		focused_ele.grab_focus();
		select_state = state_stack.pop_back();


func select_category():
	if(focused_ele == ATTACK_CATEGORY):
		select_state = SelectState.Action;
		menu_stack.push_back(curr_menu);
		focus_stack.push_back(focused_ele);
		
		curr_menu = ATTACK_LIST.get_parent();
		focused_ele = ATTACK_LIST.get_child(0);
		
		curr_menu.visible = true;
		focused_ele.grab_focus();
	elif(focused_ele == SKILL_CATEGORY):
		select_state = SelectState.Action;
		menu_stack.push_back(curr_menu);
		focus_stack.push_back(focused_ele);
		
		curr_menu = SKILL_LIST.get_parent();
		focused_ele = SKILL_LIST.get_child(0);
		
		curr_menu.visible = true;
		focused_ele.grab_focus();
	elif(focused_ele == ITEM_CATEGORY):
		select_state = SelectState.Action;
		menu_stack.push_back(curr_menu);
		focus_stack.push_back(focused_ele);
		
		curr_menu = ITEM_LIST.get_parent();
		focused_ele = ITEM_LIST.get_child(0);
		
		curr_menu.visible = true;
		focused_ele.grab_focus();
	elif(focused_ele == ESCAPE_CATEGORY):
		select_state = SelectState.Action;
		menu_stack.push_back(curr_menu);
		focus_stack.push_back(focused_ele);
		
		curr_menu = ESCAPE_LIST.get_parent();
		focused_ele = ESCAPE_LIST.get_child(0);
		
		curr_menu.visible = true;
		focused_ele.grab_focus();
