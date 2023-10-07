class_name Cursor extends Node2D


@onready var n_sprite = $Sprite2D;
@onready var animator = $AnimationPlayer;


# Called when the node enters the scene tree for the first time.
func _ready():
	print("animator - %s" % [animator]);
	_menu();


func update_pos(target):
	if(target is Control):
		transform.origin = Vector2(target.global_position.x - 12, target.global_position.y + (target.size.y / 2));


func _menu():
	print("menu - %s" % [animator]);
	animator.play(&"menu_cursor");
	

func _target_selected():
	animator.play(&"target_cursor_selected");
	

func _target_unselected():
	animator.play(&"target_cursor_unselected");
