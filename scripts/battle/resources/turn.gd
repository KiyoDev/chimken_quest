class_name Turn extends Resource

@export var character : Character


func _init(char : Character) -> void:
	character = char;


func _execute(character : Character):
	pass


func _to_string():
	return "turn - %s" % [character];
