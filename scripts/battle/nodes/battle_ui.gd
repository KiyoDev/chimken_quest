class_name BattleUI extends CanvasLayer


signal target_selected;


enum SelectState {
	None,
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

@onready var DUMMY_LIST = %DummyContainer;

#@onready var ALLY_CONTAINER = $AllyContainer;
#@onready var ENEMY_CONTAINER = $EnemyContainer;

#@export var turn_queue : Array[Turn] = [] ;

#@export var ally_turns : Array[AllyTurn] = []
#@export var enemy_turns : Array[EnemyTurn] = []

@export var current_actor : Character;

# used to know which control element to go back to on cancel
# when focus switches to a sub menu, add current focused_ele to stack, then assign new focused
@export var state_stack : Array[SelectState];
@export var select_state : SelectState;

@export var focus_stack : Array[Control]; 
@export var focused_ele : Control;

@export var menu_stack : Array[Control];
@export var curr_menu : Control;

# ActionCategories -> Attacks, Skills, Items, Escape
#		bring up another window to show attacks, skills, items
# Called when the node enters the scene tree for the first time.
func _ready():
#	print(skill_list.get_children()[0].get_children());

#	print(ACTION_CATEGORIES);
#	get_viewport().connect(&"gui_focus_changed", _on_focus_changed);
#	var default_foc : Control = ACTION_CATEGORIES.get_child(0);
#	default_foc.grab_focus();
#	focused_ele = default_foc;
#	curr_menu = ACTION_CATEGORIES;
#	select_state = SelectState.Categories;
	pass;


func _on_focus_changed(control : Control):
	print("focus changed - '%s'" % [control]);
	focused_ele = control;
	

func on_battle_start():
	visible = true;
	
	get_viewport().connect(&"gui_focus_changed", _on_focus_changed);
	ACTION_CATEGORIES.visible = true;
	var default_foc : Control = ACTION_CATEGORIES.get_child(0);
	default_foc.grab_focus();
	focused_ele = default_foc;
	curr_menu = ACTION_CATEGORIES;
	select_state = SelectState.Categories;


func on_battle_end():
	if(curr_menu != null): curr_menu.visible = false;
	if(focused_ele != null) : focused_ele.release_focus();
	state_stack.clear();
	focus_stack.clear();
	for m in menu_stack:
		m.visible = false;
	menu_stack.clear();
	select_state = SelectState.None;
	curr_menu = null;
	focused_ele = null;
	curr_menu = null;
	visible = false;


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
				if(state_stack.back() == SelectState.Action): return;
				print("action - selected '%s'" % focused_ele);
				# TODO: move on to target select if selecting an action or item
				select_action();
			SelectState.Target:
				pass;
			
	elif(!menu_stack.is_empty() && event.is_action_pressed(&"ui_cancel")):
		cancel_select();


func cancel_select():
	print("cancel select");
	if(curr_menu != null): curr_menu.visible = false;
	curr_menu = menu_stack.pop_back();
	focused_ele = focus_stack.pop_back();
	focused_ele.grab_focus();
	select_state = state_stack.pop_back();


func select_category():
	select_state = SelectState.Action;
	menu_stack.push_back(curr_menu);
	focus_stack.push_back(focused_ele);
	if(focused_ele == ATTACK_CATEGORY):
		
		curr_menu = ATTACK_LIST.get_parent();
		focused_ele = ATTACK_LIST.get_child(0);
		
	elif(focused_ele == SKILL_CATEGORY):
#		select_state = SelectState.Action;
#		menu_stack.push_back(curr_menu);
#		focus_stack.push_back(focused_ele);
		
		curr_menu = SKILL_LIST.get_parent();
		focused_ele = SKILL_LIST.get_child(0);
		
#		curr_menu.visible = true;
#		focused_ele.grab_focus();
	elif(focused_ele == ITEM_CATEGORY):
#		select_state = SelectState.Action;
#		menu_stack.push_back(curr_menu);
#		focus_stack.push_back(focused_ele);
		
		curr_menu = ITEM_LIST.get_parent();
		focused_ele = ITEM_LIST.get_child(0);
		
#		curr_menu.visible = true;
#		focused_ele.grab_focus();
	elif(focused_ele == ESCAPE_CATEGORY):
#		select_state = SelectState.Action;
#		menu_stack.push_back(curr_menu);
#		focus_stack.push_back(focused_ele);
		
		curr_menu = ESCAPE_LIST.get_parent();
		focused_ele = ESCAPE_LIST.get_child(0);
		
#		curr_menu.visible = true;
#		focused_ele.grab_focus();

	curr_menu.visible = true;
	focused_ele.grab_focus();

func select_action():
	print("selected action");
	print("curr_menu - [%s, %s]" % [curr_menu, focused_ele]);
	if(curr_menu == ESCAPE_LIST.get_parent()):
		if(focused_ele.name == "confirm"):
			BattleSystem.end_battle();
		else:
			cancel_select();
	else:
		state_stack.push_back(select_state);
		select_state = SelectState.Target;
		menu_stack.push_back(curr_menu);
		focus_stack.push_back(focused_ele);

		focused_ele.release_focus();
		
		curr_menu = DUMMY_LIST;
		focused_ele = DUMMY_LIST.get_child(0);
		
		curr_menu.visible = true;
		focused_ele.grab_focus();
		

func test_print():
	print("state=[%s], curr_menu=[%s], focused[%s]" % [SelectState.keys()[select_state], curr_menu.name if curr_menu != null else "null", focused_ele.name if focused_ele != null else "null"]);
