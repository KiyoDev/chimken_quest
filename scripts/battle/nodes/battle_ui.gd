class_name BattleUI extends CanvasLayer


signal target_selected;


enum SelectState {
	None,
	Categories,
	Action,
	Target
}

enum TargetableType {
	Ally	= 1,
	Enemy	= 2,
	Mixed	= 3
}


@onready var ActionCategories := %ActionCategories;
@onready var AttackCategory := %Attacks
@onready var SkillCategory := %Skills;
@onready var ItemCategory := %Items;
@onready var EscapeCategory := %Escape;

# TODO: attack and skill lists should have instances for each character
@onready var ATTACK_LIST := %AttackList;
# TODO: skills need to listen on character mana_updated signals; lets know if button should be disabled
@onready var SkillList := %SkillList;
@onready var _ItemList := %ItemList;
@onready var EscapeList := %EscapeList;
@onready var TargetList := %TargetList;

@onready var DummyList := %DummyContainer;

@onready var Cursor : Cursor = preload("res://scenes/ui/cursor.tscn").instantiate();
@onready var TargetCursor : TargetCursor = preload("res://scenes/ui/target_cursor.tscn").instantiate();

#@onready var ALLY_CONTAINER = $AllyContainer;
#@onready var ENEMY_CONTAINER = $EnemyContainer;

#@export var turn_queue : Array[Turn] = [] ;

#@export var ally_turns : Array[AllyTurn] = []
#@export var enemy_turns : Array[EnemyTurn] = []

#@export var curr_actor : Character;

# used to know which control element to go back to on cancel
# when focus switches to a sub menu, add current focused_ele to stack, then assign new focused
@export var state_stack : Array[SelectState];
@export var select_state : SelectState;

@export var focus_stack : Array[Control]; 
@export var focused_ele : Control;

@export var menu_stack : Array[Control];
@export var curr_menu : Control;

var curr_action : ActionDefinition;
var curr_targeted;
var targetable : Array[TargetCursor];
var targetable_type : TargetableType;

# ActionCategories -> Attacks, Skills, Items, Escape
#		bring up another window to show attacks, skills, items
# Called when the node enters the scene tree for the first time.
#func _ready():
#	print(Cursor);
##	print(skill_list.get_children()[0].get_children());
#
##	print(ActionCategories);
##	get_viewport().connect(&"gui_focus_changed", _on_focus_changed);
##	var default_foc : Control = ActionCategories.get_child(0);
##	default_foc.grab_focus();
##	focused_ele = default_foc;
##	curr_menu = ActionCategories;
##	select_state = SelectState.Categories;
#	pass;


func _input(event):
	if(!BattleSystem.in_battle): return;
	
#	if(focused_ele == null): return;
#
#	if(event.is_action_pressed(&"ui_select")):
#		# open menu corresponding to focused action category and change focus
#		match(select_state):
#			SelectState.Categories:
#				print("category - selected '%s'" % [focused_ele]);
#				select_category();
#			SelectState.Action:
#				if(state_stack.back() == SelectState.Action): return;
#				print("action - selected '%s'" % [focused_ele]);
#				# TODO: move on to target select if selecting an action or item
#				select_action(curr_action);
#			SelectState.Target:
#				print("target - using '%s' against '%s'" % [focus_stack.back().name, focused_ele.character.info.character_name])
#				(focused_ele as Control).focus
##				print("focus - %s" % [focused_ele.focus_next]);
#
#	elif(!menu_stack.is_empty() && event.is_action_pressed(&"ui_cancel")):
#		cancel_select();
#
#	if(select_state == SelectState.Target && 
#	  (event.is_action_pressed(&"ui_up") || event.is_action_pressed(&"ui_down") ||
#	   event.is_action_pressed(&"ui_left") || event.is_action_pressed(&"ui_right"))):
#		change_target();


func change_target():
	if(curr_action.targeting_type == ActionDefinition.TargetingType.AoE): return; # Do not change targets with AoE action
	var direction := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down");
	var next_target : TargetCursor = curr_targeted._change_select(direction);
	if(next_target == curr_targeted): return;
	curr_targeted = next_target;


func _on_focus_changed(control : Control):
	print("focus changed - '%s', [%s, %s]" % [control, SelectState.keys()[select_state], curr_menu]);
	focused_ele = control;
	if(select_state == SelectState.Target):
		Cursor.visible = false;
#		if(focused_ele is TargetCursor):
#			focused_ele._select();
#		Cursor._target_selected();
	else:
		if(!Cursor.visible): Cursor.visible = true;
		Cursor.position = Vector2(focused_ele.global_position.x - 12, focused_ele.global_position.y + (focused_ele.size.y / 2));
		Cursor._menu();
		
		if(select_state == SelectState.Action):
			_test_action(focused_ele.name);
	

func on_battle_start(allies, enemies):
	visible = true;
	
#	add_child(Cursor);
	get_viewport().connect(&"gui_focus_changed", _on_focus_changed);
	ActionCategories.visible = true;
	var default_foc : Control = ActionCategories.get_child(0);
	default_foc.grab_focus();
	focused_ele = default_foc;
	curr_menu = ActionCategories;
	select_state = SelectState.Categories;
	
	print("ciruir - %s, %s" % [Cursor, Cursor.n_sprite]);
	Cursor.transform.origin = Vector2(focused_ele.global_position.x - 12, focused_ele.global_position.y + (focused_ele.size.y / 2));
	init_target_cursors(allies, enemies);

# TODO: updated target selection. allow only target cursors to be focused
func init_target_cursors(allies, enemies):
	TargetList.visible = false;
	for a in allies:
		var cursor : TargetCursor = TargetCursor.duplicate();
		cursor.visible = false;
#		TargetList.get_child(0).add_child(cursor);
#		TargetList.get_node("%Allies").visible = false;
		TargetList.get_node("%Allies").add_child(cursor);
		
		print("targetea [%s, %s] (%s, %s)- %s, %s" % [a, a.n_sprite, a.n_sprite.global_position, a.n_sprite.position, cursor, cursor.n_sprite]); 
		print("texture - ally_sprite[%s], cursor[%s]" % [a.n_sprite.texture.get_width(), cursor.n_sprite.texture.get_width()]);
		cursor.character = a;
		# TODO: needs to be in top left corner of sprite
		cursor.n_sprite.global_position = Vector2(a.n_sprite.global_position.x - (a.n_sprite.texture.get_width() / 2) - (cursor.n_sprite.texture.get_width() / 8 / 2), a.n_sprite.global_position.y - (a.n_sprite.texture.get_height() / 2) - (cursor.n_sprite.texture.get_height() / 8 / 2));
		
	#- (a.n_sprite.texture.get_width() / 2) - (cursor.n_sprite.texture.get_width() / 8 / 2)
	# - (a.n_sprite.texture.get_height() / 2) - (cursor.n_sprite.texture.get_height() / 2)
	for e in enemies:
		var cursor : TargetCursor = TargetCursor.duplicate();
		cursor.visible = false;
#		TargetList.get_node("%Enemies").visible = false;
		TargetList.get_node("%Enemies").add_child(cursor);
		
		cursor.character = e;
		cursor.n_sprite.global_position = Vector2(e.n_sprite.global_position.x - (e.n_sprite.texture.get_width() / 2) - (cursor.n_sprite.texture.get_width() / 8 / 2), e.n_sprite.global_position.y - (e.n_sprite.texture.get_height() / 2) - (cursor.n_sprite.texture.get_height() / 8 / 2));


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
	_untarget();
	# Remove all targets from sub lists
	for n in TargetList.get_children():
		for c in n.get_children():
			c._unselect();
			n.remove_child(c);
	TargetList.visible = true;
	remove_child(Cursor);
	get_viewport().disconnect(&"gui_focus_changed", _on_focus_changed);


func cancel_select():
	print("cancel select");
	if(curr_menu != null): curr_menu.visible = false;
	select_state = state_stack.pop_back();
	curr_menu = menu_stack.pop_back();
	focused_ele = focus_stack.pop_back();
	focused_ele.grab_focus();
	_untarget();


func select_category():
	state_stack.push_back(select_state);
	select_state = SelectState.Action;
	menu_stack.push_back(curr_menu);
	focus_stack.push_back(focused_ele);
	if(focused_ele == AttackCategory):
		curr_menu = ATTACK_LIST.get_parent();
		focused_ele = ATTACK_LIST.get_child(0);
	elif(focused_ele == SkillCategory):
		curr_menu = SkillList.get_parent();
		focused_ele = SkillList.get_child(0);
	elif(focused_ele == ItemCategory):
		curr_menu = _ItemList.get_parent();
		focused_ele = _ItemList.get_child(0);
	elif(focused_ele == EscapeCategory):
		curr_menu = EscapeList.get_parent();
		focused_ele = EscapeList.get_child(0);

	curr_menu.visible = true;
	focused_ele.grab_focus();


func select_action(action):
	print("selected action");
	print("curr_menu - [%s, %s]" % [curr_menu, focused_ele]);
	if(curr_menu == EscapeList.get_parent()):
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
		
		_test_action(focused_ele.name);
		
		_target();
#		curr_menu = DummyList;
#		focused_ele = DummyList.get_child(0);
		
		curr_menu = TargetList;
		focused_ele = TargetList.get_child(0).get_child(0);
		print("chose action, focused - %s" % [focused_ele]);
		
#		TargetList.visible = true;
		
		curr_menu.visible = true;
		focused_ele.grab_focus();

# TODO: action button have references to action
func _target():
	targetable_type = 0;
	targetable.clear();
	if(curr_action.target & ActionDefinition.Target.Self > 0):
		# self, curr_actor
		if(BattleSystem.current_actor.info.type == CharacterDefinition.Type.Ally):
			print("targeting ally self");
			targetable_type |= TargetableType.Ally;
			var allies = TargetList.get_node("%Allies");
			for a in allies.get_children():
				print("a - %s" % [a.character.info.character_name]);
				if(a.character.info.character_name == BattleSystem.current_actor.info.character_name):
					allies.visible = true;
					targetable.push_back(a);
					curr_targeted = a;
					curr_targeted._select();
					print("is self - %s, %s" % [a.is_selected, a.visible]);
					break;
		else:
			targetable_type |= TargetableType.Enemy;
			var enemies = TargetList.get_node("%Enemies");
			for e in enemies.get_children():
				if(e.character.info.character_name == BattleSystem.current_actor.info.character_name):
					enemies.visible = true;
					targetable.push_back(e);
					curr_targeted = e;
					curr_targeted._select();
					break;
	else:
		if(curr_action.target & ActionDefinition.Target.Ally > 0):
			targetable_type |= TargetableType.Ally;
			var allies = TargetList.get_node("%Allies");
			allies.visible = true;
			var i := 0;
			for a in allies.get_children():
				a._show();
				targetable.push_back(a); # TODO: update neighbor directions
#				if(i > 0): targetable[i - 1].
				i += 1;
			
		if(curr_action.target & ActionDefinition.Target.Enemy > 0):
			targetable_type |= TargetableType.Enemy;
			var enemies = TargetList.get_node("%Enemies");
			enemies.visible = true;
			for e in enemies.get_children():
				e._show();
				targetable.push_back(e);
				
		if(curr_action.targeting_type == ActionDefinition.TargetingType.Single):
			curr_targeted = targetable[0];
			curr_targeted._select();
			print("single target... %s, %s" % [curr_targeted.name, curr_targeted.visible]);
		else:
			curr_targeted = [];
			for t in targetable:
				t._select();
				curr_targeted.push_back(t);
				
	set_target_neighbors();


func set_target_neighbors():
	var ally_count = TargetList.get_node("%Allies").get_child_count();
	match(targetable.size()):
		2: #2, 1:1
			if(ally_count == 1):
				# a e
				targetable[0].neighbor_right = targetable[1];
				targetable[1].neighbor_left = targetable[0];
			else:
				# a/e
				#
				# a/e
				targetable[0].neighbor_down = targetable[1];
				targetable[1].neighbor_up = targetable[0];
		3:	# 3, 2:1, 1:2
			if(ally_count == 3 || ally_count == 0):
				#      a/e
				# a/e   
				#      a/e
				targetable[0].neighbor_down = targetable[1];
				targetable[1].neighbor_up = targetable[0];
				targetable[0].neighbor_left = targetable[2];
				targetable[1].neighbor_left = targetable[2];
				targetable[2].neighbor_right = targetable[0];
				targetable[2].neighbor_up = targetable[0];
				targetable[2].neighbor_down = targetable[1];
			elif(ally_count == 2):
				# a
				#    e
				# a
				targetable[0].neighbor_down = targetable[1];
				targetable[1].neighbor_up = targetable[0];
				targetable[0].neighbor_right = targetable[2];
				targetable[1].neighbor_right = targetable[2];
				targetable[2].neighbor_left = targetable[0];
			else:
				#    e
				# a
				#    e
				targetable[0].neighbor_right = targetable[1];
				targetable[0].neighbor_up = targetable[1];
				targetable[0].neighbor_down = targetable[2];
				targetable[1].neighbor_left = targetable[0];
				targetable[2].neighbor_left = targetable[0];
				targetable[1].neighbor_down = targetable[2];
				targetable[2].neighbor_up = targetable[1];
		4: # 4, 3:1, 2:2, 1:3
			if(ally_count == 4 || ally_count == 0):
				#    a/e
				# a/e
				#    a/e
				# a/e
				targetable[0].neighbor_down = targetable[1];
				targetable[0].neighbor_left = targetable[2];
				targetable[1].neighbor_up = targetable[0];
				targetable[1].neighbor_left = targetable[3];
				
				targetable[2].neighbor_right = targetable[0];
				targetable[2].neighbor_down = targetable[3];
				targetable[2].neighbor_up = targetable[0];
				targetable[3].neighbor_right = targetable[1];
				targetable[3].neighbor_up = targetable[2];
			elif(ally_count == 3):
				#    a
				# a     e
				#    a
				targetable[0].neighbor_down = targetable[1];
				targetable[1].neighbor_up = targetable[0];
				targetable[0].neighbor_left = targetable[2];
				targetable[1].neighbor_left = targetable[2];
				targetable[2].neighbor_right = targetable[0];
				targetable[2].neighbor_up = targetable[0];
				targetable[2].neighbor_down = targetable[1];
				
				targetable[0].neighbor_right = targetable[3];
				targetable[1].neighbor_right = targetable[3];
				targetable[3].neighbor_left = targetable[0];
				targetable[3].neighbor_up = targetable[0];
				targetable[3].neighbor_down = targetable[1];
			elif(ally_count == 2):
				# a  e
				#
				# a  e
				targetable[0].neighbor_down = targetable[1];
				targetable[1].neighbor_up = targetable[0];
				targetable[0].neighbor_right = targetable[2];
				targetable[1].neighbor_right = targetable[3];
				
				targetable[2].neighbor_down = targetable[3];
				targetable[3].neighbor_up = targetable[2];
				targetable[2].neighbor_left = targetable[0];
				targetable[3].neighbor_left = targetable[1];
			else:
				#       e
				# a  e
				#       e
				targetable[0].neighbor_right = targetable[3];
				targetable[3].neighbor_left = targetable[0];
				
				targetable[1].neighbor_down = targetable[2];
				targetable[2].neighbor_up = targetable[1];
				targetable[1].neighbor_left = targetable[3];
				targetable[2].neighbor_left = targetable[3];
				
				targetable[3].neighbor_right = targetable[1];
				targetable[3].neighbor_up = targetable[1];
				targetable[3].neighbor_down = targetable[2];
	


func _untarget():
	curr_targeted = null;
	for t in targetable:
		t._unselect();
	targetable.clear();
	TargetList.get_node("%Allies").visible = false;
	TargetList.get_node("%Enemies").visible = false;


func _test_action(ele_name):
	print("ele_name='%s'" % [ele_name]);
	if(ele_name == "potion"):
		var potion = ActionDefinition.new();
		potion.name = ele_name;
		potion.category = ActionDefinition.Category.Skill;
		potion.target = ActionDefinition.Target.Ally;
		potion.targeting_type = ActionDefinition.TargetingType.Single;
		curr_action = potion;
	elif(ele_name == "focus"):
		var focus = StatusEffectAction.new();
		focus.name = ele_name;
		focus.category = ActionDefinition.Category.Skill;
		focus.target = ActionDefinition.Target.Self;
		focus.targeting_type = ActionDefinition.TargetingType.Single;
		curr_action = focus;
	elif(ele_name == "avalanche"):
		var ava = DamageAction.new();
		ava.name = ele_name;
		ava.category = ActionDefinition.Category.Skill;
		ava.target = ActionDefinition.Target.All;
		ava.targeting_type = ActionDefinition.TargetingType.AoE;
		curr_action = ava;
	elif(ele_name == "chain_frost"):
		var cf = DamageAction.new();
		cf.name = ele_name;
		cf.category = ActionDefinition.Category.Skill;
		cf.target = ActionDefinition.Target.Enemy;
		cf.targeting_type = ActionDefinition.TargetingType.AoE;
		curr_action = cf;
	elif(ele_name == "mass_heal"):
		var mh = HealAction.new();
		mh.name = ele_name;
		mh.category = ActionDefinition.Category.Skill;
		mh.target = ActionDefinition.Target.Ally;
		mh.targeting_type = ActionDefinition.TargetingType.AoE;
		curr_action = mh;
	else:
		var atk = DamageAction.new();
		atk.name = ele_name;
		atk.category = ActionDefinition.Category.Attack;
		atk.target = ActionDefinition.Target.Enemy;
		atk.targeting_type = ActionDefinition.TargetingType.Single;
		curr_action = atk;
	print("curr_action='%s'" % [curr_action]);

func test_print():
	print("state=[%s], curr_menu=[%s], focused[%s]" % [SelectState.keys()[select_state], curr_menu.name if curr_menu != null else "null", focused_ele.name if focused_ele != null else "null"]);
	print("targeting - '%s' using '%s' against [%s, %s]" % [BattleSystem.current_actor, curr_action.name, curr_targeted, targetable]);
