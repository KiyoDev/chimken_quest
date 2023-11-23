@tool
class_name RootNode extends BaseNode


signal branch_play_requested(slot : int)

const NODE_TYPE = "Root"

@export var ConditionConfig : HBoxContainer

@export var condition_element : PackedScene


var curr_condition_count := 1

var condition_elements = []


func _init():
	print_debug("init dialogue node")



#func _exit_tree():
#	print_debug("'%s' exiting tree..." % [name])


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("ready")
#	add_child(condition_element.instantiate())
#	set_slot_enabled_right(ConditionConfig.get_index() + 1, true)


func set_from_dict(dict : Dictionary):
	for c in condition_elements:
		c.queue_free()

	for condition in dict.conditions:
		var con := add_condition()
		con.condition.text = condition.condition
	
	position_offset = Vector2(dict.metadata.position.x, dict.metadata.position.y)
	custom_minimum_size = Vector2(dict.metadata.custom_minimum_size.x, dict.metadata.custom_minimum_size.y)
	print_debug("root[%s] - %s" % [dict.name, dict.metadata.position])


func to_dict() -> Dictionary:
	var dict := {
		"name": name,
		"node_type": NODE_TYPE,
		"conditions": [],
		"properties": {},
		"metadata": {
			"position": {"x": position_offset.x, "y": position_offset.y},
			"size": {"x": size.x, "y": size.y},
			"custom_minimum_size": {"x": custom_minimum_size.x, "y": custom_minimum_size.y}
		}
	}
	
	# TODO: add connections but maybe is just managed by the graph editor itself
	# response index = node port for the editor connections
#	print_debug("hhh '%s'" % [get_children()])
	for index in range(ConditionConfig.get_parent().get_index() + 1, get_child_count()):
		var child : ConditionElement = get_child(index)
#		print_debug("lakdhgjklad '%s', '%s'" % [child.condition.name, child.condition.text])
		dict["conditions"].append({
			"condition": child.condition.text
		})
#			print_debug("responses - %s" % [get_responses()])
#	return "{\"name\":\"%s\"}" % []
	return dict


func to_dict_no_meta() -> Dictionary:
	var dict := {
		"name": name,
		"node_type": NODE_TYPE,
		"conditions": [],
		"properties": {}
	}
	
	# TODO: add connections but maybe is just managed by the graph editor itself
	# response index = node port for the editor connections
#	print_debug("hhh '%s'" % [get_children()])
	for index in range(ConditionConfig.get_parent().get_index() + 1, get_child_count()):
		var child : ConditionElement = get_child(index)
#		print_debug("lakdhgjklad '%s', '%s'" % [child.condition.name, child.condition.text])
		dict["conditions"].append({
			"condition": child.condition.text
		})
#			print_debug("responses - %s" % [get_responses()])
#	return "{\"name\":\"%s\"}" % []
	return dict


func add_condition() -> ConditionElement:
	var new_condition := condition_element.instantiate()
	add_child(new_condition)
	condition_elements.append(new_condition)
	new_condition.delete_requested.connect(_on_delete_condition_pressed)
	new_condition.branch_play_requested.connect(_on_branch_play_requested)
	set_slot_enabled_right(get_child_count() - 1, true)
	reset_size()
	
	return new_condition


func delete_condition(condition : ConditionElement):
	slots_removed.emit(self, condition.get_index() - 1)
	condition_elements.erase(condition)
	condition.queue_free()
	reset_size()


func _clone(flags := 0b0111):
	var node := super.duplicate(flags)
	return node


func _on_close_request():
	print_debug("Cannot close root node?")


func _on_add_condition_pressed():
	add_condition()


func _on_delete_condition_pressed(condition : ConditionElement):
	delete_condition(condition)


func _on_branch_play_requested(condition : ConditionElement):
	branch_play_requested.emit(condition.get_index() - 1)


func _on_play_pressed():
	branch_play_requested.emit(0)
