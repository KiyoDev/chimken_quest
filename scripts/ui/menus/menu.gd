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
	hide();


func _navigate(move, horizontal):
	if(!visible || !is_focused || option_count() == 0): 
		print("trying to navigate an unfocused menu [%s]" % [name]);
		return;
	var option : OptionBase;
	print("is h - %s, %s, (%s)" % [horizontal, select_wrap, move]);
	if(Options is VBoxContainer):
		if(horizontal): return option;
		if(select_wrap):
			option = navigate_wrap(move.y);
		else: # FIXME: Options.get_child_count() doesn't take hidden children into acocunt
			option = try_get_option(clampi(focused_index + move.y, 0, option_count() - 1));
	elif(Options is HBoxContainer):
		if(!horizontal): return option;
		if(select_wrap):
			option = navigate_wrap(move.x);
		else:
			option = try_get_option(clampi(focused_index + move.x, 0, option_count() - 1));
	elif(Options is GridContainer):
		if(select_wrap):
			var index := focused_index;
			var columns : int = Options.columns;
			var size := option_count();
			
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
				
			option = try_get_option(index);
		else:
			option = try_get_option(focused_index + move.x + move.y * Options.columns);
			
	return option;


func navigate_wrap(direction_value) -> OptionBase:
	if(direction_value > 0):
		return try_get_option((focused_index + 1) % option_count());
	elif(direction_value < 0):
		return try_get_option((focused_index - 1 + option_count()) % option_count());
	return null;


func try_get_option(index) -> OptionBase:
	print("try get - %s, ch-'%s'" % [index, option_count()]);
	print(Options.get_children());
	if(index < 0 || index >= option_count()): 
		return null;
	
	# Only change index if option is visible to prevent navigating to invalid options
	if(!Options.get_child(index).visible):
		return null;
	
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
#			opt.show(); # will show all the sub children, don't want that
			print("option '%s' - %s" % [opt.name, opt.global_position]);
		var default_option : OptionBase = _get_current_option();
		default_option._focus();
		return default_option;
	return null;


func _exit():
	print("Exiting Menu - '%s'" % [self]);
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
	for opt in Options.get_children():
		opt._hide();
	var current_option = Options.get_child(focused_index);
	if(current_option): current_option._unfocus();
	hide();


func _reset():
	for opt in Options.get_children():
		opt._reset();
	var current_option = Options.get_child(focused_index);
	if(current_option): 
		current_option._unfocus();
	focused_index = 0;


func _select_option():
	if(option_count() == 0): return;
	_unfocus();
	var curr := _get_current_option();
	print("opt - %s" % [curr]);
	
	var option = curr._selected();
	print("option '%s'" % [option]);
	if(option == null):
		return null;
		
	print("selecting option on '%s'[children=%s, i=%s]" % [name, option_count(), focused_index]);
	return option;


func _get_current_option() -> OptionBase:
	return Options.get_child(focused_index);


func _cancel():
	if(hide_when_unfocused):
		_hide()
	else:
		_unfocus();


func _add_option(option : OptionBase):
	Options.add_child(option);


func _remove_option_by_index(index : int):
	Options.remove_child(get_option(index));


func _remove_option(option : OptionBase):
	Options.remove_child(option);


func get_option(index : int) -> OptionBase:
	print("getting - [%s, %s]" % [index, option_count()])
	if(index < 0 || index >= option_count()): 
		return null;
	return Options.get_child(index);


func get_options() -> Array[Node]:
	return Options.get_children();


func option_count() -> int:
	return Options.get_child_count();
