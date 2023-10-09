class_name VMenu extends BaseMenu
# no reference to possible previous menus; should have some menu manager to take care of inputs and menu stacks


@export var wrap := false;


var focused_index := 0;


func _ready():
	visible = false;
	
	
func _navigate(direction):
	if(!is_focused || get_child_count() == 0): return get_child(focused_index);
	
	if(wrap):
		if(direction.y > 0): # down
			focused_index = (focused_index + 1) % get_child_count();
		elif(direction.y < 0): # up
			focused_index = (focused_index - 1 + get_child_count()) % get_child_count();
	else:
		if(direction.y > 0): # down
			focused_index = min(focused_index + 1, get_child_count() - 1);
		elif(direction.y < 0): # up
			focused_index = max(focused_index - 1, 0);
	return get_child(focused_index);

func _on_focus():
	super._on_focus();


func _on_unfocus():
	super._on_unfocus();


func _open():
	visible = true;


func _select():
	var child = get_child(focused_index);
	child.visible = true;
	return child;


func _cancel():
	visible = false;
