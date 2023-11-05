@tool
class_name VariableElement extends HBoxContainer


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
