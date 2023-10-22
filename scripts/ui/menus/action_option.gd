class_name ActionOption extends OptionBase


signal action_selected;


@onready var NameLabel : Label = $Layout/Container/Name;
@onready var CostLabel : Label = $Layout/Container/Cost;

@export var action : ActionDefinition;


func _ready():
	super._ready();


func clone() -> ActionOption:
	return duplicate();


func _selected():
	print_debug("_selected action '%s'" % [name]);
	super._selected();
	action_selected.emit(self)
	return null; # TODO: implement


func _focus():
	if(selectable):
		Animator.play(&"focused_selectable") 
	else:
		Animator.play(&"focused_unselectable");


func _unfocus():
	Animator.play(&"unfocused");


func _on_menu_closed():
	super._on_menu_closed();
	print_debug("closing '%s'" % [name]);


func _show():
	show();


func _hide():
	pass;
#	hide();
	

func swap_action(action : ActionDefinition):
	name = action.name;
	NameLabel.text = action.name;
	CostLabel.text = str(action.cost) if action.cost > 0 else "";


func on_character_resources_changed(character : Character, resource : Dictionary):
	var cost := int(CostLabel.text) if CostLabel.text.length() > 0 else 0;
	var current_resource = character.info.curr_mp; # TODO: update if adding more resources (ultimate charges, etc)
	
	selectable = current_resource >= cost;
	if(!selectable):
		if(!NameLabel.has_theme_color_override(&"font_color")):
			NameLabel.add_theme_color_override(&"font_color", Color(100, 100, 100));
		if(!CostLabel.has_theme_color_override(&"font_color")):
			CostLabel.add_theme_color_override(&"font_color", Color(100, 100, 100));
	else:
		if(NameLabel.has_theme_color_override(&"font_color")):
			NameLabel.remove_theme_color_override(&"font_color");
		if(CostLabel.has_theme_color_override(&"font_color")):
			CostLabel.remove_theme_color_override(&"font_color");


func _to_string():
	return "'%s'['%s', '%s']" % [name, NameLabel.text, CostLabel.text];
