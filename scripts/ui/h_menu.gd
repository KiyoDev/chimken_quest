# no reference to possible previous menus; should have some menu manager to take care of inputs and menu stacks
class_name HMenu extends BaseMenu

# childrene are the elements
#@export var elements := [];

var focused_index := 0;


func _ready():
	visible = false;


func _navigate(direction):
	if(!is_focused): return;
	if(direction.x > 0): # right
		focused_index = (focused_index + 1) % get_child_count();
	elif(direction.x < 0): # left
		focused_index = (focused_index - 1 + get_child_count()) % get_child_count();
	return get_child(focused_index);


func _on_focus():
	super._on_focus();


func _on_unfocus():
	super._on_unfocus();
	
	
func _open():
	visible = true;
	

func _select():
	return get_child(focused_index);


func _cancel():
	visible = false;
