class_name MultipleChoiceElement extends GraphElement

# TODO: query this list to populate choice menu for ui
@export var choices : Array[GraphElement] = [];


func get_next(index) -> GraphElement:
	return choices[index];
