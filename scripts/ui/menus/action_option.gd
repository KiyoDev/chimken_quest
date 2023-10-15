class_name ActionOption extends OptionBase


signal action_selected;


#@onready var Sprite : Sprite2D = $Sprite2D;
@onready var NameLabel : Label = $Layout/Container/Name;
@onready var CostLabel : Label = $Layout/Container/Cost;

@export var action : ActionDefinition:
	set(act):
		action = act;
	get:
		return action;


func _ready():
	super._ready();


func _selected():
	print("_selected action '%s'" % [name]);
	super._selected();
	action_selected.emit(self);
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
	print("closing '%s'" % [name]);


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
