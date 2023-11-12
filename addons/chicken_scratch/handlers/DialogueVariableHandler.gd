@tool
class_name DialogueVariableHandler extends Node

const VARIABLE_PATTERN := "(?<variable>\\${[a-zA-Z_]+[\\w\\.]*})"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func parse_text(text : String) -> String:
	var parsed := text
	var variable_match := RegEx.create_from_string(VARIABLE_PATTERN)
	var found := variable_match.search_all(text)
	
	for v in found:
		var name := v.get_string("variable")
		parsed = parsed.replace(name, str(get_variable(name)))
	
	return parsed


func get_autoloads() -> Array[Node]:
	var autoloads := []
	for child in get_tree().root.get_children():
		autoloads.append(child)
	return autoloads


# TODO: be able to get dialogue from an autoload utilizing paths .
func get_variable(name : String):
	name = name.trim_prefix("${").trim_suffix("}")
	if '.' in name:
		var value = null
		var split := name.split('.')
		var len := split.size()
		var key := split[0]
		
		# check autoloads first
		for autoload in get_autoloads():
			if key == autoload.name:
				print_debug("autoload variable")
				key = split[1]
				return autoload.call(key) if autoload.has_method(key) else autoload.get(key)
		
		var dict := ChickenScratch.variables;
		for i in range(1, len):
			if key.is_empty() || !dict.has(key): return null
			
			if i == len - 1:
				value = dict[key]
				break
			
			dict = dict[key]
			key = split[i]
		
		return value
	else:
		return ChickenScratch.variables.get(name)
