class_name DialogueTrigger extends Resource


@export var fail_dialogue : GraphElement;


func _can_trigger(obj = null) -> bool:
	return true;
