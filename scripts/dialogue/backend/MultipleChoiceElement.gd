class_name MultipleChoiceElement extends DialogueBase

# TODO: query this list to populate choice menu for ui
@export var choices : Array[DialogueBase] = [];


func get_next(index) -> DialogueBase:
	return choices[index];
