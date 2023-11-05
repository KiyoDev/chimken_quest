@tool
class_name VariableCondition extends HBoxContainer

#	var variable_match = RegEx.new()
#	variable_match.compile("\\${\\w+}");

enum Type {
	STRING,
	INT,
	FLOAT,
	BOOL
}

enum Op {
	EQUALS,
	NOT_EQUALS,
	LESS_THAN,
	LESS_THAN_OR_EQUAL_TO,
	GREATER_THAN,
	GREATER_THAN_OR_EQUAL_TO
}


@export var type_menu : OptionButton;
@export var op_menu : OptionButton;

@export var value_container : MarginContainer;
@export var string_value : LineEdit;
@export var int_value : SpinBox;
@export var float_value : SpinBox;
@export var bool_value : CheckBox;

@export var type := Type.STRING;


func _read():
	for child in value_container.get_children():
		child.hide();
	match(type):
		Type.STRING:
			string_value.show();
		Type.INT:
			int_value.show();
		Type.FLOAT:
			float_value.show();
		Type.BOOL:
			bool_value.show();


func _on_menu_button_item_selected(index):
	print_debug("index[%s]=%s" % [index, Type.keys()[index]]);
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
