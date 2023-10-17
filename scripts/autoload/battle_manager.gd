extends Node


signal battle_started;
signal battle_ended;


@onready var BattleUI = %BattleUI;
#@onready var MenuContainer = %BattleUI/Container/MainMenu;
#@onready var SubMenuContainer = %BattleUI/Container/SubMenu;
@onready var AllyContainer := $AllyContainer;
@onready var EnemyContainer := $EnemyContainer;
@onready var BattleMenuTest = preload("res://scenes/ui/battle_menu.tscn").instantiate();


@export var turn_queue : Array[Turn] = [];

@export var ally_turns : Array[AllyTurn] = []
@export var enemy_turns : Array[EnemyTurn] = []

@export var current_actor : Character;

var battle_menu_manager : BattleMenuManager;

var round := 0;
var in_battle := false;


@onready var test_chimken = preload("res://scenes/characters/chimken_overworld.tscn").instantiate();
@onready var test_enemy = preload("res://scenes/characters/test_enemy.tscn").instantiate();
#@onready var test_chimken = Image.load_from_file("res://assets/characters/test/test_chimken.png");

func _ready():
	get_viewport();
	battle_menu_manager = BattleMenuManager.new();
	battle_menu_manager.show();
	add_child(battle_menu_manager);
#	DisplayServer.window_set_min_size(Vector2i(960, 540))


func _input(event):
	_test(event);
	

signal test_mp_change;


func _test(event):
	if(event.is_action_pressed(&"test_battle_start")):
		if(in_battle): return;
		print("Start battle...");
		in_battle = true;
		# TODO: normally would get populated based on party list & encountered enemy
		var c1 = test_generate_character("Chimken", 10, AllyContainer);
		var c2 = test_generate_character("Chonken", 5, AllyContainer);
		var e1 = test_generate_character("Bad Chimken", 6, EnemyContainer, "Enemy");
		var e2 = test_generate_character("Bad Chimken 2", 4, EnemyContainer, "Enemy");
		
		c1.position = Vector2(0, 0);
		c2.position = Vector2(c1.position.x, c1.position.y + 32);
		e1.position = Vector2(c1.position.x + 64, c1.position.y + 16);
		e2.position = Vector2(e1.position.x, e1.position.y + 32);
		
		print("c1 - %s" % [c1.position]);
		print("e2 - %s" % [e2.position]);
		for  a in AllyContainer.get_children():
			print("char - %s, %s, [%s, '%s']" % [a.info.character_name, a.get_instance_id(), a.info, a.info.resource_path])
		print("battleele - %s, %s" % [AllyContainer.get_children(), EnemyContainer.get_children()]);
#		AllyContainer.add_child(c1);
#		AllyContainer.add_child(c2);
#		# TODO: instantiate enemies from a list based on the area
#		EnemyContainer.add_child(e1);
#		EnemyContainer.add_child(e2);
		
		init_battle(AllyContainer.get_children(), EnemyContainer.get_children());
#		BattleUI.on_battle_start(AllyContainer.get_children(), EnemyContainer.get_children());

		battle_menu_manager.on_battle_started(AllyContainer.get_children());
		Game.battle();
	elif(event.is_action_pressed(&"test_battle_end")):
		end_battle();
	elif(event.is_action_pressed(&"test_battle_print")):
		pass;
#		test_print();
	
#	if(event is InputEventKey):
#		if((event as InputEventKey).keycode == KEY_O):
#			print("MenuController - O");
#			battle_menu_manager.on_battle_started(AllyContainer.get_children());
#			Game.battle();
#		elif((event as InputEventKey).keycode == KEY_Q):
#			end_battle();


func test_generate_character(name, speed, node : Node, type := "Ally"):
	var char : Character = test_chimken.duplicate() if type == "Ally" else test_enemy.duplicate();
	char.info = char.info.duplicate();
#	test_chimken
	node.add_child(char);
	char.info.character_name = name;
	char.info.speed = speed;
	
#	var texture : ImageTexture = ImageTexture.create_from_image(test_chimken);
#	char.n_sprite.texture = texture;
#	char.n_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
#	print("char - %s, %s, %s, [%s, '%s']" % [char.info.character_name, char.n_sprite, char.get_instance_id(), char.info, char.info.resource_path]);
#	print("cont - %s" % [node.get_children()]);
	return char;


#func test_print():
#	print("allies - %s" % [AllyContainer.get_children()]);
#	print("enemies - %s" % [EnemyContainer.get_children()]);
#	print("turn_queue %s" % [turn_queue]);
#	print("turn queue - %s"  % turn_queue);
#	print(ActionDefinition.target_type("All"));
#	BattleUI.test_print();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func init_battle(allies, enemies):
	# init battle, calculate turn order, create turns
	# TODO: populate ally and enemy containers
	# TODO: populate lists of actions for each character that can swap out when turns change
	print("initializing battle...");
	round = 0;
	
	# TODO: init character action label dictionary in BattleMenuManager;
	
	for a in allies:
		ally_turns.append(AllyTurn.new(a as Character));
	
	for e in enemies:
		enemy_turns.append(EnemyTurn.new(e as Enemy));
	
#	print("ally  turns  -  %s" % [ally_turns]);
#	print("enemy  turns  -  %s" % [enemy_turns]);
	
	new_round();


func end_battle():
	if(!in_battle): return;
	in_battle = false;
	print("End battle");
	
	battle_menu_manager.on_battle_ended();
	for n in AllyContainer.get_children():
		AllyContainer.remove_child(n);
		
	for n in EnemyContainer.get_children():
		EnemyContainer.remove_child(n);
		
	turn_queue.clear();
	Game.overworld();


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
#	print("before - %s" % [turn_queue]);
	calc_turn_order();
	round += 1;
	
	start_turn();


func calc_turn_order():
	turn_queue.sort_custom(
		func(a : Turn, b : Turn): 
#			print("a=[%s] b=[%s]" % [a, b]);
			return a.character.info.speed > b.character.info.speed
	);


func _on_attacks_focus_entered():
	print("focus on attacks category");
	pass # Replace with function body.
