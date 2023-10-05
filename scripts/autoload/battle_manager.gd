extends Node


@onready var BATTLE_UI = %BattleUI;
@onready var ALLY_CONTAINER := $AllyContainer;
@onready var ENEMY_CONTAINER := $EnemyContainer;

@export var turn_queue : Array[Turn] = [];

@export var ally_turns : Array[AllyTurn] = []
@export var enemy_turns : Array[EnemyTurn] = []

@export var current_actor : Character;

static var round := 0;
static var in_battle := false;


func _ready():
	pass


func _input(event):
	_test(event);
	

func _test(event):
	if(event.is_action_pressed(&"test_battle_start")):
		if(in_battle): return;
		print("Start battle...");
		in_battle = true;
		# TODO: normally would get populated based on party list & encountered enemy
		var c1 = test_generate_character("Chimken", 10);
		var c2 = test_generate_character("Chonken", 5);
		var e1 = test_generate_character("Bad Chimken", 6, "Enemy");
		
		c2.transform.origin = Vector2(c1.transform.origin.x, c1.transform.origin.y + 32);
		e1.transform.origin = Vector2(c1.transform.origin.x + 64, c1.transform.origin.y + 16);
		
		ALLY_CONTAINER.add_child(c1);
		ALLY_CONTAINER.add_child(c2);
		ENEMY_CONTAINER.add_child(e1);
		
		BATTLE_UI.on_battle_start();
		init_battle(ALLY_CONTAINER.get_children(), ENEMY_CONTAINER.get_child(0));
		pass;
	elif(event.is_action_pressed(&"test_battle_end")):
		end_battle();
	elif(event.is_action_pressed(&"test_battle_print")):
		test_print();

@onready var test_chimken = Image.load_from_file("res://assets/characters/test/test_chimken.png");

func test_generate_character(name, speed, type := "Ally"):
	var char = Character.new() if type == "Ally" else Enemy.new();
	char.info.character_name = name;
	char.info.speed = speed;
	
	var sprite = Sprite2D.new();
	var texture : ImageTexture = ImageTexture.create_from_image(test_chimken);
	sprite.texture = texture;
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
	char.add_child(sprite);
	
	return char;


func test_print():
	print("allies - %s" % [ALLY_CONTAINER.get_children()]);
	print("enemies - %s" % [ENEMY_CONTAINER.get_children()]);
	print("turn_queue %s" % [turn_queue]);
#	print("turn queue - %s"  % turn_queue);
	BATTLE_UI.test_print();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func init_battle(allies, enemy):
	# init battle, calculate turn order, create turns
	# TODO: populate ally and enemy containers
	# TODO: populate lists of actions for each character that can swap out when turns change
	# TODO: instantiate enemies from a list based on the area
	print("initializing battle...");
	round = 0;
	var enemy_list : Array[Character] = [enemy.duplicate(), enemy.duplicate()];
	
	for a in allies:
		ally_turns.append(AllyTurn.new(a as Character));
	
	for e in enemy_list:
		enemy_turns.append(EnemyTurn.new(e));
	
	print("ally  turns  -  %s" % [ally_turns]);
	print("enemy  turns  -  %s" % [enemy_turns]);
	
	new_round();


func end_battle():
	if(!in_battle): return;
	in_battle = false;
	print("End battle");
	BATTLE_UI.on_battle_end();
	
	for n in ALLY_CONTAINER.get_children():
		ALLY_CONTAINER.remove_child(n);
		
	for n in ENEMY_CONTAINER.get_children():
		ENEMY_CONTAINER.remove_child(n);
		
	turn_queue.clear();


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
	print("before - %s" % [turn_queue]);
	calc_turn_order();
	round += 1;


func calc_turn_order():
	turn_queue.sort_custom(func(a : Turn, b : Turn): return a.character.info.speed > b.character.info.speed);


func _on_attacks_focus_entered():
	print("focus on attacks category");
	pass # Replace with function body.
