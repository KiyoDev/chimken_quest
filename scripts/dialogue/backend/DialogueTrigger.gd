class_name DialogueTrigger extends Resource


@export var fail_dialogue : DialogueBase;


func _can_trigger(obj = null) -> bool:
	return true;
