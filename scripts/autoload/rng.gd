extends Node

var values : Array[float] = []:
	set(value):
		pass; # do not set new array
		

func _ready():
	if(values.size() == 0): generate_values();
	# TODO: store values somewhere and set_values(...) from that file. if game is reset, rng values should still be the same


func next_value() -> float:
	if(values.size() == 0): generate_values();
	var value = values.pop_front();
	values.push_back(randf_range(0.00, 1.00)); # push another value
	return value;


func generate_values() -> void:
	if(values.size() > 0): values.clear();
	for i in 50:
		values.push_back(randf_range(0.00, 1.00));


func set_values(new_values : Array[float]) -> void:
	if(values.size() > 0): values.clear();
	for val in new_values:
		values.push_back(val);


func reset() -> void:
	values.clear();
