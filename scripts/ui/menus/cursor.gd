class_name Cursor extends Node2D


signal focus_changed;
signal option_selected;
signal menu_closed;


@onready var Sprite = $Sprite2D;
@onready var Animator = $AnimationPlayer;


var focused_opt : OptionBase;


# Called when the node enters the scene tree for the first time.
func _ready():
#	print("Animator - %s" % [Animator]);
	hide();



func _reset(next : OptionBase):
	change_focus(next);
	

func _menu():
#	print("menu - %s" % [Animator]);
	Animator.play(&"menu_cursor");


func _show():
	show();
	
	
func _hide():
	hide();
	

func open(next : OptionBase):
	_menu();
	on_menu_open(next);
	show();


func close():
	hide();
	menu_closed.emit();


func change_focus(next):
	if(next == null): return;
	if(focused_opt != null): 
		focused_opt._unfocus(); # unfocus previous option
		
	focused_opt = next;
	focused_opt._focus(); # focus new option
	focus_changed.emit(focused_opt);
	update_pos(focused_opt);


func update_pos(option : OptionBase):
#	print("updating cursor pos - [%s, %s]" % [global_position, option.global_position]);
	global_position = Vector2(option.global_position.x - 5, option.global_position.y + (option.size.y / 2));


func on_menu_open(next):
	await get_tree().create_timer(0.001).timeout
	change_focus(next);

