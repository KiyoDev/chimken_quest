class_name VMenu extends MenuBase
# no reference to possible previous menus; should have some menu manager to take care of inputs and menu stacks


@onready var Background := $Background;
@onready var Options := $Options;


@export var wrap := false;
@export var hide_when_unfocused := true;


var focused_index := 0;


func _ready():
	super._ready();
	hide();
	
	
func _navigate(direction):
	if(!is_focused || Options.get_child_count() == 0): 
		print("trying to navigate an unfocused menu....");
		return Options.get_child(focused_index);
	
	if(wrap):
		if(direction.y > 0): # down
			focused_index = (focused_index + 1) % Options.get_child_count();
		elif(direction.y < 0): # up
			focused_index = (focused_index - 1 + Options.get_child_count()) % Options.get_child_count();
	else:
		if(direction.y > 0): # down
			focused_index = min(focused_index + 1, Options.get_child_count() - 1);
		elif(direction.y < 0): # up
			focused_index = max(focused_index - 1, 0);
	return Options.get_child(focused_index);


func _focus():
	super._focus();


func _unfocus():
	super._unfocus();


func _open():
	_show();
	_focus();
	var default_option : OptionBase = Options.get_child(0);
	if(default_option): default_option._focus();
	return default_option;


func _exit():
	print("Exiting MenuBase - '%s'" % [self]);
	_hide();
	menu_closed.emit();
	focused_index = 0;
	

func _try_exit():
	print("Trying to exit...");
	if(!escapeable): return;
	print("Exited");
	_hide();
	focused_index = 0;
	

func _hide():
	super._hide();
	var current_option = Options.get_child(focused_index);
	if(current_option): current_option._unfocus();


func _select_option():
	print("'%s'[%s, i=%s]" % [name, Options.get_child_count(), focused_index]);
	if(Options.get_child_count() == 0): return;
	
	_unfocus();
	return _get_current_option()._selected();


func _get_current_option():
	return Options.get_child(focused_index);


func _cancel():
	if(hide_when_unfocused):
		_hide()
	else:
		_unfocus();
