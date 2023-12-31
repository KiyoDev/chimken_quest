class_name MenuBase extends MarginContainer


signal menu_closed


@export var Background : NinePatchRect
@export var MenuLayout : VBoxContainer
@export var Title : Label
@export var Options : Container

@export var select_wrap := false
@export var escapeable := true
@export var hide_when_unfocused := true

var is_focused := false
var focused_index := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for opt in Options.get_children():
		if(!(opt is MenuOptionBase)): continue
		menu_closed.connect(opt._on_menu_closed)
	hide()


func _navigate(move, horizontal):
	if(!visible || !is_focused || option_count() == 0): 
		print_debug("trying to navigate an unfocused menu [%s]" % [name])
		return
	var option : MenuOptionBase
	print_debug("is h - %s, %s, (%s)" % [horizontal, select_wrap, move])
	if(Options is VBoxContainer):
		if(horizontal): return option
		if(select_wrap):
			option = navigate_wrap(move.y)
		else: # FIXME: Options.get_child_count() doesn't take hidden children into acocunt
			option = try_get_option(clampi(focused_index + move.y, 0, option_count() - 1))
	elif(Options is HBoxContainer):
		if(!horizontal): return option
		if(select_wrap):
			option = navigate_wrap(move.x)
		else:
			option = try_get_option(clampi(focused_index + move.x, 0, option_count() - 1))
	elif(Options is GridContainer):
		if(select_wrap):
			var index := focused_index
			var columns : int = Options.columns
			var size := option_count()
			
			if(move.x > 0): # right
				index = (focused_index + 1) % columns + ((focused_index / columns) * columns)
			elif(move.x < 0): # left
				index = focused_index + columns - 1 if (focused_index % columns == 0) else focused_index - 1
			elif(move.y > 0): # down
				# (focused_index + colums) % (size)
				index = (focused_index + columns) % size
			elif(move.y < 0): # up
				# (focused_index - columns + (size)) % (size)
				index = (focused_index - columns + size) % size
				
			option = try_get_option(index)
		else:
			option = try_get_option(focused_index + move.x + move.y * Options.columns)
			
	return option


func navigate_wrap(direction_value) -> MenuOptionBase:
	if(direction_value > 0):
		return try_get_option((focused_index + 1) % option_count())
	elif(direction_value < 0):
		return try_get_option((focused_index - 1 + option_count()) % option_count())
	return null


func try_get_option(index) -> MenuOptionBase:
	print_debug("try get - %s, option count-'%s'" % [index, option_count()])
#	print(Options.get_children())
	if(index < 0 || index >= option_count()): 
		return null
	
	# Only change index if option is visible to prevent navigating to invalid options
	if(!Options.get_child(index).visible):
		return null
	
	focused_index = index
	return Options.get_child(index)
	
	
## Connect callable to all menu's options' signals
func _connect_option_selected(callable):
	for opt in Options.get_children():
#		print_debug("connecting '%s' to '%s'" % [callable, opt])
		opt._connect_option_selected(callable)
		
		
## Disconnect callable to all menu's options' signals
func _disconnect_option_selected(callable):
	for opt in Options.get_children():
		opt._disconnect_option_selected(callable)


func _focus():
	is_focused = true
#	print_debug("default_option - %s" % [Options.get_child(focused_index).global_position])


func _unfocus():
	is_focused = false


func _open():
	_show()
	_focus()
#	focused_index = 0
	if(Options.get_child_count() > 0):
		for opt in Options.get_children():
#			opt.show() # will show all the sub children, don't want that
			print_debug("option '%s' - %s" % [opt.name, opt.global_position])
		var default_option : MenuOptionBase = _get_current_option()
		default_option._focus()
		return default_option
	return null


func _exit():
	print_debug("Exiting Menu - '%s'" % [self])
	_hide()
	for opt in Options.get_children():
		opt._exit()
	menu_closed.emit()
	focused_index = 0
	

func _try_exit():
	print_debug("Trying to exit...")
	if(!escapeable): return
	print_debug("Exited")
	_hide()
	focused_index = 0


func _show():
	show()
	

func _hide():
	for opt in Options.get_children():
		opt._hide()
	var current_option = Options.get_child(focused_index)
	if(current_option): current_option._unfocus()
	hide()


func _reset():
	for opt in Options.get_children():
		opt._reset()
	var current_option = Options.get_child(focused_index)
	if(current_option): 
		current_option._unfocus()
	focused_index = 0


func _select_option():
	if(option_count() == 0): return
	_unfocus()
	var curr := _get_current_option()
	print_debug("opt - %s" % [curr])
	
	var option = curr._selected()
	print_debug("option '%s'" % [option])
	if(option == null):
		return null
		
	print_debug("selecting option on '%s'[children=%s, i=%s]" % [name, option_count(), focused_index])
	return option


func _get_current_option() -> MenuOptionBase:
	return Options.get_child(focused_index)


func _cancel():
	if(hide_when_unfocused):
		_hide()
	else:
		_unfocus()


func _add_option(option : MenuOptionBase):
	Options.add_child(option)


func _remove_option_by_index(index : int):
	Options.remove_child(get_option(index))


func _remove_option(option : MenuOptionBase):
	Options.remove_child(option)


func get_option(index : int) -> MenuOptionBase:
	print_debug("getting - [%s, %s]" % [index, option_count()])
	if(index < 0 || index >= option_count()): 
		return null
	return Options.get_child(index)


func get_options() -> Array[Node]:
	return Options.get_children()


func option_count() -> int:
	return Options.get_child_count()
