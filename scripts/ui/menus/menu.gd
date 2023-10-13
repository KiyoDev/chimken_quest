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


func ping():
	print("ping");


func _navigate(direction):
	if(!is_focused || Options.get_child_count() == 0): 
		print("trying to navigate an unfocused menu....");
		return;
	var option : OptionBase;
	if(Options is VBoxContainer):
		if(select_wrap):
			option = navigate_wrap(direction.y);
		else:
			option = get_option(clampi(focused_index + direction.y, 0, Options.get_child_count() - 1));
	elif(Options is HBoxContainer):
		if(select_wrap):
			option = navigate_wrap(direction.x);
		else:
			option = get_option(clampi(focused_index + direction.x, 0, Options.get_child_count() - 1));
	elif(Options is GridContainer):
		if(select_wrap):
			pass;
		else:
			option = get_option(focused_index + direction.x + direction.y * Options.columns);
			
	if(option):
		option._focus();
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
#			var size = (rows * Options.columns);
#			if(direction.x > 0): # right
#				focused_index = (focused_index + 1) % columns + ((focused_index / columns) * columns);
#			elif(direction.x < 0): # left
#				focused_index = focused_index + columns - 1 if (focused_index % columns == 0) else focused_index - 1;
#			elif(direction.y > 0): # down
#				# (focused_index + colums) % (size)
#				focused_index = (focused_index + columns) % size;
#			elif(direction.y < 0): # up
#				# (focused_index - columns + (size)) % (size)
#				focused_index = (focused_index - columns + size) % size;
#			return get_child(focused_index);
#		else:
#			if(direction.x > 0): # right
#				focused_index = min((focused_index / columns + 1) * columns - 1, focused_index + 1);
#			elif(direction.x < 0): # left
#				focused_index = max((focused_index / columns) * columns, focused_index - 1);
#			elif(direction.y > 0): # down
#				# curr - ((curr / columns) * columns) = column index
#				# (r * c) - c = last row
#				focused_index = min((focused_index - (focused_index / columns) * columns) + ((rows * columns) - columns), focused_index + columns);
#				pass;
#			elif(direction.y < 0): # up
#				# (curr - colums + (r*c)) % (r*c)
#				focused_index = max((focused_index - (focused_index / columns) * columns), focused_index - columns);



func connect_cursor_to_menu(cursor : Cursor):
	for opt in Options.get_children():
		if(opt.has_method("connect_to_menu_selected")):
			opt.connect_to_menu_selected(cursor);
		

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
	
	_unfocus();
	print("selecting option on '%s'[children=%s, i=%s]" % [name, Options.get_child_count(), focused_index]);
	return _get_current_option()._selected();


func _get_current_option():
	return Options.get_child(focused_index);


func _cancel():
	if(hide_when_unfocused):
		_hide()
	else:
		_unfocus();
