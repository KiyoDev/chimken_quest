@tool
class_name DialogueTreeLoader extends ResourceFormatLoader

## Returns all valid extensions
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["cst"])


func _handles_type(typename: StringName) -> bool:
	return ClassDB.is_parent_class(typename, "Resource")
