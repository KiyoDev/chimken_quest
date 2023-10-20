class_name ItemTrigger extends DialogueTrigger

@export var item : ItemDefinition;



# TODO: pass ItemDefinition here
func _can_trigger(obj = null) -> bool:
	return obj == item;
