@tool
class_name VariableValue extends HBoxContainer


signal delete_requested(node : Node)

signal name_changed(prev, new)

signal value_changed(name, value)


enum Type {
	STRING,
	INT,
	FLOAT,
	BOOL
}


@export var variable_name : LineEdit
@export var type_button : OptionButton
@export var value_container : MarginContainer
@export var string_value : LineEdit
@export var int_value : SpinBox
@export var float_value : SpinBox
@export var bool_value : CheckBox


@export var type := Type.STRING


var _name_cache := ""


func _ready():
	_name_cache = variable_name.text


func var_name() -> String:
	return variable_name.text


#func as_dict() -> Dictionary:
#	return {
#		"name": variable_name.text,
#		"type": Type.keys()[type],
#		"value": value()
#	}

## Sets the name and value input fields to the given values. Hides
func set_variable(name : String, value : Variant):
	variable_name.text = name
	_name_cache = name
	
	if value is String:
		swap_type(Type.STRING)
		string_value.text = value
	elif value is int:
		swap_type(Type.INT)
		int_value.value = value
	elif value is float:
		swap_type(Type.FLOAT)
		float_value.value = value
	elif value is bool:
		swap_type(Type.BOOL)
		bool_value.button_pressed = value


func swap_type(new_type : Type):
	match(type):
		Type.STRING:
			string_value.hide()
		Type.INT:
			int_value.hide()
		Type.FLOAT:
			float_value.hide()
		Type.BOOL:
			bool_value.hide()
	
	match(new_type):
		Type.STRING:
			string_value.show()
		Type.INT:
			int_value.show()
		Type.FLOAT:
			float_value.show()
		Type.BOOL:
			bool_value.show()
	
	type = new_type
	type_button.selected = type

#func from_dict(dict : Dictionary):
#	variable_name.text = dict.name
#	_name_cache = dict.name
#	type = Type[dict.type]
#	type_button.selected = type
#	print("type - %s" % type)
#	for child in value_container.get_children():
#		child.hide()
#	match(type):
#		Type.STRING:
#			string_value.text = dict.value
#			string_value.show()
#		Type.INT:
#			int_value.value = dict.value
#			int_value.show()
#		Type.FLOAT:
#			float_value.value = dict.value
#			float_value.show()
#		Type.BOOL:
#			bool_value.set_pressed_no_signal(dict.value)
#			bool_value.show()


func value():
	match(type_button.selected):
		Type.STRING:
			return string_value.text
		Type.INT:
			return int_value.value
		Type.FLOAT:
			return float_value.value
		Type.BOOL:
			return bool_value.button_pressed


func _on_menu_button_item_selected(index):
	swap_type(index)
#	type = index
#	for child in value_container.get_children():
#		child.hide()
#	match(index):
#		Type.STRING:
#			string_value.show()
#		Type.INT:
#			int_value.show()
#		Type.FLOAT:
#			float_value.show()
#		Type.BOOL:
#			bool_value.show()


func _on_delete_pressed():
	delete_requested.emit(self)


func _on_string_value_text_changed(new_text):
	value_changed.emit(var_name(), new_text)


func _on_int_value_value_changed(value):
	value_changed.emit(var_name(), value)


func _on_float_value_value_changed(value):
	value_changed.emit(var_name(), value)


func _on_bool_value_pressed():
	value_changed.emit(var_name(), bool_value.button_pressed)

# TODO: connect editor to this signal to update variable dictionaries
func _on_variable_name_changed(new_name):
	name_changed.emit(_name_cache, new_name)
	_name_cache = new_name
