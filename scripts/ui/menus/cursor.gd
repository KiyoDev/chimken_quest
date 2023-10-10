class_name Cursor extends Node2D


@onready var n_sprite = $Sprite2D;
@onready var animator = $AnimationPlayer;


# Called when the node enters the scene tree for the first time.
func _ready():
	print("animator - %s" % [animator]);
	_menu();


func _on_navigate(element):
	global_position = element._cursor_position(n_sprite);
#	n_sprite.global_position = Vector2(element.n_sprite.global_position.x - (element.n_sprite.texture.get_width() / 2) - (n_sprite.texture.get_width() / 8 / 2), element.n_sprite.global_position.y - (element.n_sprite.texture.get_height() / 2) - (n_sprite.texture.get_height() / 8 / 2));


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
