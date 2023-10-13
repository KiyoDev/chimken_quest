# no reference to possible previous menus; should have some menu manager to take care of inputs and menu stacks
class_name HMenu extends MenuBase

# childrene are the elements
#@export var elements := [];

@export var wrap := false;


var focused_index := 0;


func _ready():
	visible = false;


func _navigate(direction):
	if(!is_focused || get_child_count() == 0): return get_child(focused_index);
	
	if(wrap):
		if(direction.x > 0): # right
			focused_index = (focused_index + 1) % get_child_count();
		elif(direction.x < 0): # left
			focused_index = (focused_index - 1 + get_child_count()) % get_child_count();
	else:
		if(direction.x > 0): # right
			focused_index = min(focused_index + 1, get_child_count() - 1);
		elif(direction.x < 0): # left
			focused_index = max(focused_index - 1, 0);
	return get_child(focused_index);


func _focus():
	super._focus();


func _unfocus():
	super._unfocus();
	
	
func _open():
	visible = true;
	

func _select_option():
	return get_child(focused_index);


func _cancel():
	visible = false;
