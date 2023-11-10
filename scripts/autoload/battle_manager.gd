extends Node


signal battle_started;
signal battle_ended;


@onready var BattleUI = %BattleUI;
#@onready var MenuContainer = %BattleUI/Container/MainMenu;
#@onready var SubMenuContainer = %BattleUI/Container/SubMenu;
@onready var AllyContainer := $AllyContainer;
@onready var EnemyContainer := $EnemyContainer;

@export var battle_menu_manager_scn : PackedScene;
#@onready var BattleMenuTest = preload("res://scenes/ui/battle_menu.tscn").instantiate();


@export var turn_queue : Array[Turn] = [];

@export var ally_turns : Array[AllyTurn] = []
@export var enemy_turns : Array[EnemyTurn] = []

@export var current_actor : Character;

var battle_menu_manager : BattleMenuManager;

var round := 0;
var in_battle := false;


@onready var test_chimken = preload("res://scenes/characters/chimken_overworld.tscn").instantiate();
@onready var test_chonken = preload("res://scenes/characters/chonken.tscn").instantiate();
@onready var test_enemy = preload("res://scenes/characters/test_enemy.tscn").instantiate();
#@onready var test_chimken = Image.load_from_file("res://assets/characters/test/test_chimken.png");

func _ready():
	get_viewport();
	battle_menu_manager = battle_menu_manager_scn.instantiate();
	battle_menu_manager.show();
	add_child(battle_menu_manager);
	
	battle_menu_manager.battle_escaped.connect(on_battle_escaped);
#	DisplayServer.window_set_min_size(Vector2i(960, 540))



func _input(event):
	_test(event);
	

signal test_mp_change;


func _test(event):
	if(event.is_action_pressed(&"test_battle_start")):
		if(in_battle): return;
		print_debug("Start battle...");
		in_battle = true;
		# TODO: normally would get populated based on party list & encountered enemy
		var c1 = test_generate_character("Chimken", 10, AllyContainer, test_chimken._clone());
		var c2 = test_generate_character("Chonken", 5, AllyContainer, test_chonken._clone());
		var e1 = test_generate_character("Bad Chimken", 6, EnemyContainer, test_enemy._clone());
		var e2 = test_generate_character("Bad Chimken 2", 4, EnemyContainer, test_enemy._clone());
		
		c1.position = Vector2(0, 0);
		c2.position = Vector2(c1.position.x, c1.position.y + 32);
		e1.position = Vector2(c1.position.x + 64, c1.position.y + 16);
		e2.position = Vector2(e1.position.x, e1.position.y + 32);
		
		print_debug("c1 - %s" % [c1.position]);
		print_debug("e2 - %s" % [e2.position]);
		for  a in AllyContainer.get_children():
			print_debug("char - %s, %s, [%s, '%s']" % [a.info.character_name, a.get_instance_id(), a.info, a.info.resource_path])
		print_debug("battleele - %s, %s" % [AllyContainer.get_children(), EnemyContainer.get_children()]);
#		AllyContainer.add_child(c1);
#		AllyContainer.add_child(c2);
#		# TODO: instantiate enemies from a list based on the area
#		EnemyContainer.add_child(e1);
#		EnemyContainer.add_child(e2);
		
		battle_menu_manager.on_battle_started(AllyContainer.get_children());
		
		init_battle(AllyContainer.get_children(), EnemyContainer.get_children());
#		BattleUI.on_battle_start(AllyContainer.get_children(), EnemyContainer.get_children());

	elif(event.is_action_pressed(&"test_battle_end")):
		end_battle();
	elif(event.is_action_pressed(&"test_battle_print")):
		pass;
#		test_print();
	
	if(event is InputEventKey):
		var just_pressed = event.is_pressed() && !event.is_echo();
		if(just_pressed):
			if(!in_battle): return;
			if((event as InputEventKey).keycode == KEY_T):
	#			Game.battle();
				start_turn();
#			elif((event as InputEventKey).keycode == KEY_Q):
#	#			end_battle();
#				pass;


func test_generate_character(name, speed, node : Node, char : Character):
	node.add_child(char);
	char.info.character_name = name;
	char.info.speed = speed;
	return char;


#func test_print():
#	print_debug("allies - %s" % [AllyContainer.get_children()]);
#	print_debug("enemies - %s" % [EnemyContainer.get_children()]);
#	print_debug("turn_queue %s" % [turn_queue]);
#	print_debug("turn queue - %s"  % turn_queue);
#	print(ActionDefinition.target_type("All"));
#	BattleUI.test_print();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func init_battle(allies, enemies):
	Game.battle();
	# init battle, calculate turn order, create turns
	# TODO: populate ally and enemy containers
	# TODO: populate lists of actions for each character that can swap out when turns change
	print_debug("initializing battle...");
	round = 0;
	
	# TODO: init character action label dictionary in BattleMenuManager;
	
	for a in allies:
		ally_turns.append(AllyTurn.new(a as Character));
	
	for e in enemies:
		enemy_turns.append(EnemyTurn.new(e as Enemy));
	
#	print_debug("ally  turns  -  %s" % [ally_turns]);
#	print_debug("enemy  turns  -  %s" % [enemy_turns]);
	
	start_turn();


func end_battle():
	if(!in_battle): return;
	in_battle = false;
	print_debug("End battle");
	
	battle_menu_manager.on_battle_ended();
	for n in AllyContainer.get_children():
		AllyContainer.remove_child(n);
		
	for n in EnemyContainer.get_children():
		EnemyContainer.remove_child(n);
		
	turn_queue.clear();
	round = 0;
	Game.overworld();


func new_round():
	turn_queue.append_array(ally_turns);
	turn_queue.append_array(enemy_turns);
#	print_debug("before - %s" % [turn_queue]);
	calc_turn_order();
	round += 1;
	print_debug("Round(%s) - %s" % [round, turn_queue]);


func start_turn():
	current_actor = get_next_turn().character;
	print_debug("current_actor - %s" % [current_actor]);
	if(current_actor.info.type == CharacterDefinition.Type.Ally):
		battle_menu_manager.swap_actions(current_actor);
	else:
		battle_menu_manager._hide_menu();
	# TODO: implement


func on_end_turn():
	pass;


func get_next_turn() -> Turn:
	if(turn_queue.is_empty()):
		new_round();
	
	return turn_queue.pop_front();
	

func calc_turn_order():
	turn_queue.sort_custom(
		func(a : Turn, b : Turn): 
			return a.character.info.speed > b.character.info.speed
	);


func on_battle_escaped():
	end_battle();
