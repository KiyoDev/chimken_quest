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


func get_autoloads() -> Array:
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
		
		# check autoloads first; can call autoload method or get property
		var current_obj = null
		for autoload in get_autoloads():
#			print_debug("autoload[%s] %s" % [autoload.name, key])
			if key == autoload.name:
				current_obj = autoload
				# check for nested properties/methods
				for i in range(1, len):
					key = split[i]
#					print_debug("ket[%s] %s-%s" % [key, current_obj, current_obj.get(key)])
					if(key.is_empty() || !current_obj): return null
					
					if i == len - 1:
						return current_obj.get(key) if current_obj is Dictionary || !current_obj.has_method(key) else current_obj.call(key)
					current_obj = current_obj.get(key)
					
		key = split[0]
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
