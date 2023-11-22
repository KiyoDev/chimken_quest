@tool
class_name SelectCursor extends Node2D


@onready var sprite : Sprite2D = $Main
@onready var shadow : Sprite2D = $Main/Shadow
@onready var animator : AnimationPlayer = $AnimationPlayer


func start():
	animator.play("moving")


func update_pos(node : Control):
#	print_debug("updating cursor pos - [%s, %s]" % [global_position, option.global_position]);
	global_position = Vector2(node.global_position.x - 22, node.global_position.y - 3 );
