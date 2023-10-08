extends Node


@onready var BattleUI = %BattleUI;
@onready var AllyContainer := $AllyContainer;
@onready var EnemyContainer := $EnemyContainer;

@export var turn_queue : Array[Turn] = [];

@export var ally_turns : Array[AllyTurn] = []
@export var enemy_turns : Array[EnemyTurn] = []

@export var current_actor : Character;

var round := 0;
var in_battle := false;


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
#		AllyContainer.add_child(c1);
#		AllyContainer.add_child(c2);
#		# TODO: instantiate enemies from a list based on the area
#		EnemyContainer.add_child(e1);
#		EnemyContainer.add_child(e2);
		
		init_battle(AllyContainer.get_children(), EnemyContainer.get_children());
		BattleUI.on_battle_start(AllyContainer.get_children(), EnemyContainer.get_children());
		pass;
	elif(event.is_action_pressed(&"test_battle_end")):
		end_battle();
	elif(event.is_action_pressed(&"test_battle_print")):
		test_print();


@onready var test_chimken = preload("res://scenes/characters/test_character.tscn").instantiate();
@onready var test_enemy = preload("res://scenes/characters/test_enemy.tscn").instantiate();
#@onready var test_chimken = Image.load_from_file("res://assets/characters/test/test_chimken.png");


func test_generate_character(name, speed, node : Node, type := "Ally"):
	var char = test_chimken.duplicate() if type == "Ally" else test_enemy.duplicate();
	node.add_child(char);
#	if(char.n_sprite == null): char.n_sprite = Sprite2D.new();
	char.info.character_name = name;
	char.info.speed = speed;
	
#	var texture : ImageTexture = ImageTexture.create_from_image(test_chimken);
#	char.n_sprite.texture = texture;
#	char.n_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
	print("char - %s, %s" % [char.info.character_name, char.n_sprite.name]);
	return char;


func test_print():
#	print("allies - %s" % [AllyContainer.get_children()]);
#	print("enemies - %s" % [EnemyContainer.get_children()]);
#	print("turn_queue %s" % [turn_queue]);
#	print("turn queue - %s"  % turn_queue);
#	print(ActionDefinition.target_type("All"));
	BattleUI.test_print();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func init_battle(allies, enemies):
	# init battle, calculate turn order, create turns
	# TODO: populate ally and enemy containers
	# TODO: populate lists of actions for each character that can swap out when turns change
	print("initializing battle...");
	round = 0;
	
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
	BattleUI.on_battle_end();
	
	for n in AllyContainer.get_children():
		AllyContainer.remove_child(n);
		
	for n in EnemyContainer.get_children():
		EnemyContainer.remove_child(n);
		
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
