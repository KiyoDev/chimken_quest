class_name Cursor extends Node2D


@onready var Sprite = $Sprite2D;
@onready var Animator = $AnimationPlayer;


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Animator - %s" % [Animator]);
	_menu();


func _on_navigate(option):
	global_position = option._cursor_global_position();


func update_pos(target):
	if(target is Control):
		transform.origin = Vector2(target.global_position.x - 12, target.global_position.y + (target.size.y / 2));


func _menu():
#	print("menu - %s" % [Animator]);
	Animator.play(&"menu_cursor");
	

func _target_selected():
	Animator.play(&"target_cursor_selected");
	

func _target_unselected():
	Animator.play(&"target_cursor_unselected");
