class_name VMenu extends MenuBase
# no reference to possible previous menus; should have some menu manager to take care of inputs and menu stacks


@export var wrap := false;
@export var hide_when_unfocused := true;


var focused_index := 0;


func _ready():
	super._ready();
	visible = false;
	
	
func _navigate(direction):
	if(!is_focused || get_child_count() == 0): 
		print("trying to navigate an unfocused menu....");
		return get_child(focused_index);
	
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


func _focus():
	super._focus();


func _unfocus():
	super._unfocus();


func _open():
	_show();
	_focus();
	return get_child(0);


func _try_exit():
	print("Trying to exit...");
	if(!escapeable): return;
	print("Exited");
	_hide();
	

func _hide():
	super._hide(); 


func _select_option():
	print("'%s'[%s, i=%s]" % [name, get_child_count(), focused_index]);
	if(get_child_count() == 0): return;
	
	_unfocus();
	return _get_current_option()._selected();


func _get_current_option():
	return get_child(focused_index);


func _cancel():
	_hide() if hide_when_unfocused else _unfocus();
