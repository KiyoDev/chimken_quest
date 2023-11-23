class_name SignalNode extends BaseNode


const NODE_TYPE = "Signal"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func to_dict() -> Dictionary:
	var dict := {
		"name": name,
		"node_type": NODE_TYPE,
		# TODO: put signal node stuff here
		"properties": {},
		"metadata": {
			"position": {"x": position_offset.x, "y": position_offset.y},
			"size": {"x": size.x, "y": size.y},
			"custom_minimum_size": {"x": custom_minimum_size.x, "y": custom_minimum_size.y}
		}
	}
	return dict


func to_dict_no_meta() -> Dictionary:
	var dict := {
		"name": name,
		"node_type": NODE_TYPE,
		# TODO: put signal node stuff here
		"properties": {}
	}
	return dict
