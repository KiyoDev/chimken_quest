class_name Menu extends MarginContainer


signal menu_closed;


@onready var Background := $Background;
@onready var MenuLayout := $MenuLayout;
@onready var Title := $MenuLayout/Title;
@onready var Options := $MenuLayout/Options/Container;

@export var select_wrap := false;
@export var escapeable := true;
@export var hide_when_unfocused := true;

var is_focused := false;
var focused_index := 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	for opt in Options.get_children():
		menu_closed.connect(opt._on_menu_closed);
	_hide();


func _navigate(move, horizontal):
	if(!is_focused || Options.get_child_count() == 0): 
		print("trying to navigate an unfocused menu....");
		return;
	var option : OptionBase;
	if(Options is VBoxContainer):
		if(horizontal): return option;
		if(select_wrap):
			option = navigate_wrap(move.y);
		else:
			option = get_option(clampi(focused_index + move.y, 0, Options.get_child_count() - 1));
	elif(Options is HBoxContainer):
		if(!horizontal): return option;
		if(select_wrap):
			option = navigate_wrap(move.x);
		else:
			option = get_option(clampi(focused_index + move.x, 0, Options.get_child_count() - 1));
	elif(Options is GridContainer):
		if(select_wrap):
			var index := focused_index;
			var columns : int = Options.columns;
			var size := Options.get_child_count();
			
			if(move.x > 0): # right
				index = (focused_index + 1) % columns + ((focused_index / columns) * columns);
			elif(move.x < 0): # left
				index = focused_index + columns - 1 if (focused_index % columns == 0) else focused_index - 1;
			elif(move.y > 0): # down
				# (focused_index + colums) % (size)
				index = (focused_index + columns) % size;
			elif(move.y < 0): # up
				# (focused_index - columns + (size)) % (size)
				index = (focused_index - columns + size) % size;
				
			option = get_option(index);
		else:
			option = get_option(focused_index + move.x + move.y * Options.columns);
			
	return option;


func navigate_wrap(direction_value):
	if(direction_value > 0):
		return get_option((focused_index + 1) % Options.get_child_count());
	elif(direction_value < 0):
		return get_option((focused_index - 1 + Options.get_child_count()) % Options.get_child_count());


func get_option(index):
	if(index < 0 || index >= Options.get_child_count()): return null;
	
	focused_index = index;
	return Options.get_child(index);
	
	
## Connect callable to all menu's options' signals
func _connect_option_selected(callable):
	for opt in Options.get_children():
#		print("connecting '%s' to '%s'" % [callable, opt]);
		opt._connect_option_selected(callable);
		
		
## Disconnect callable to all menu's options' signals
func _disconnect_option_selected(callable):
	for opt in Options.get_children():
		opt._disconnect_option_selected(callable);


func _focus():
	is_focused = true;
#	print("default_option - %s" % [Options.get_child(focused_index).global_position]);


func _unfocus():
	is_focused = false;


func _open():
	_show();
	_focus();
#	focused_index = 0;
	if(Options.get_child_count() > 0):
		for opt in Options.get_children():
			opt.show();
			print("option '%s' - %s" % [opt.name, opt.global_position]);
		var default_option : OptionBase = _get_current_option();
		default_option._focus();
		return default_option;
	return null;


func _exit():
	print("Exiting MenuBase - '%s'" % [self]);
	_hide();
	for opt in Options.get_children():
		opt._exit();
	menu_closed.emit();
	focused_index = 0;
	

func _try_exit():
	print("Trying to exit...");
	if(!escapeable): return;
	print("Exited");
	_hide();
	focused_index = 0;


func _show():
	show();
	

func _hide():
	var current_option = Options.get_child(focused_index);
	if(current_option): current_option._unfocus();
	hide();


func _select_option():
	if(Options.get_child_count() == 0): return;
	var curr := _get_current_option();
	print("opt - %s" % [curr]);
	
	var option = curr._selected();
	print("option '%s'" % [option]);
	if(option == null):
		return null;
		
	_unfocus();
	print("selecting option on '%s'[children=%s, i=%s]" % [name, Options.get_child_count(), focused_index]);
	return option;


func _get_current_option() -> OptionBase:
	return Options.get_child(focused_index);


func _cancel():
	if(hide_when_unfocused):
		_hide()
	else:
		_unfocus();
