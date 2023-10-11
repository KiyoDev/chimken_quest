class_name TargetCursor extends Control

@onready var n_sprite := $Sprite2D;

@onready var animator := $AnimationPlayer;


var character : Character;

var is_selected := false;

var can_be_targeted := false;

var neighbor_up : TargetCursor;
var neighbor_down : TargetCursor;
var neighbor_left : TargetCursor;
var neighbor_right : TargetCursor;

func _ready():
#	print("ioin - %s, %s" % [n_sprite, animator]);
	_unselect();


func _select():
	print("TargetCursor - selected [%s]" % [character.info]);
	animator.play(&"target_cursor_selected");
	_show();
	is_selected = true;


func _unselect():
	animator.play(&"target_cursor_unselected");
	is_selected = false;


func _change_select(direction) -> TargetCursor:
	if(direction.x > 0):
		if(neighbor_right != null):
			_unselect();
			neighbor_right._select();
			return neighbor_right;
	elif(direction.x < 0):
		if(neighbor_left != null):
			_unselect();
			neighbor_left._select();
			return neighbor_left;
	elif(direction.y > 0): 
		if(neighbor_down != null):
			_unselect();
			neighbor_down._select();
			return neighbor_down;
	elif(direction.y < 0): 
		if(neighbor_up != null):
			_unselect();
			neighbor_up._select();
			return neighbor_up;
	return self;


func _show():
	show();


func _hide():
	hide();


# Used to tell if character can be targeted by an action; get target type from action
func _can_be_targeted(target_type):
	can_be_targeted = (target_type & character.info.type > 0);
