@tool
class_name DialogueTreeSaver extends ResourceFormatSaver


## Returns all valid extensions
func _get_recognized_extensions(resource : Resource) -> PackedStringArray:
	return PackedStringArray(["cst"])

## Returns true if the resource is DialogueTree
func _recognize(resource : Resource) -> bool:
	return resource as DialogueTree != null

## Saves the resource to file
func _save(resource : Resource, path : String = "", flags := 0) -> Error:
	print("saving resource custom")
	if(resource.get_meta("tree_saved", true)):
		pass

	print_debug("saving DialogueTree")

	var file := FileAccess.open(path, FileAccess.WRITE)
	if(!file):
		print("Error opening DialogueTree file:", FileAccess.get_open_error())
		return ERR_CANT_OPEN
	file.store_string(resource.to_dict())
	file.close()

	return OK
