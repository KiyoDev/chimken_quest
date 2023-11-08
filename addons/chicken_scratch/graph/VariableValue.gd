@tool
class_name VariableValue extends HBoxContainer


signal delete_requested(node : Node);

signal value_changed(name, value);


enum Type {
	STRING,
	INT,
	FLOAT,
	BOOL
}


@export var variable_name : LineEdit;
@export var type_button : OptionButton;
@export var value_container : MarginContainer;
@export var string_value : LineEdit;
@export var int_value : SpinBox;
@export var float_value : SpinBox;
@export var bool_value : CheckBox;


@export var type := Type.STRING;


func var_name() -> String:
	return variable_name.text;


func as_dict() -> Dictionary:
	return {
		"name": variable_name.text,
		"type": Type.keys()[type],
		"value": value()
	};


func from_dict(dict : Dictionary):
	variable_name.text = dict.name;
	type = Type[dict.type];
	type_button.selected = type;
	print("type - %s" % type);
	for child in value_container.get_children():
		child.hide();
	match(type):
		Type.STRING:
			string_value.text = dict.value;
			string_value.show();
		Type.INT:
			int_value.value = dict.value;
			int_value.show();
		Type.FLOAT:
			float_value.value = dict.value;
			float_value.show();
		Type.BOOL:
			bool_value.set_pressed_no_signal(dict.value);
			bool_value.show();


func value():
	match(type_button.selected):
		Type.STRING:
			return string_value.text;
		Type.INT:
			return int_value.value;
		Type.FLOAT:
			return float_value.value;
		Type.BOOL:
			return bool_value.button_pressed;


func _on_menu_button_item_selected(index):
	type = index;
	for child in value_container.get_children():
		child.hide();
	match(index):
		Type.STRING:
			string_value.show();
		Type.INT:
			int_value.show();
		Type.FLOAT:
			float_value.show();
		Type.BOOL:
			bool_value.show();


func _on_delete_pressed():
	delete_requested.emit(self);


func _on_string_value_text_changed(new_text):
	value_changed.emit(var_name(), new_text);


func _on_int_value_value_changed(value):
	value_changed.emit(var_name(), value);


func _on_float_value_value_changed(value):
	value_changed.emit(var_name(), value);


func _on_bool_value_pressed():
	value_changed.emit(var_name(), bool_value.button_pressed);
