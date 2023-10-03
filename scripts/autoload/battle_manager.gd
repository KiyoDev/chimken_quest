extends Node


@onready var battle_ui = %BattleUI;
@onready var action_categories = %ActionCategories;
@onready var ally_container = $AllyContainer;
@onready var enemy_container = $EnemyContainer;

@export var turn_queue : Array[Turn] = [];

@export var ally_turns : Array[AllyTurn] = []
@export var enemy_turns : Array[EnemyTurn] = []

@export var actor : Character;

# ActionCategories -> Attacks, Skills, Items, Escape
#		bring up another window to show attacks, skills, items
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func init_battle(allies : Array[Character], enemy : Character):
	# init battle, calculate turn order, create turns
	# TODO: instantiate enemies from a list based on the area
	var enemy_list : Array[Character] = [enemy.duplicate(), enemy.duplicate()];
	
	for a in allies:
		ally_turns.append(AllyTurn.new(a));
	
	for e in enemy_list:
		enemy_turns.append(EnemyTurn.new(e));
	
	new_round();


func end_battle():
	pass 


func start_turn():
	pass;


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


func calc_turn_order():
	turn_queue.sort_custom(func(a : Turn, b : Turn): return a.character.info.speed > b.character.info.speed);
