class_name VButton extends Button



# Called when the node enters the scene tree for the first time.
func _ready():
	set_focus_neighbor(SIDE_LEFT, get_path());
	set_focus_neighbor(SIDE_RIGHT, get_path());
	var p := get_parent();
	var index := get_index();
	set_focus_neighbor(SIDE_TOP, p.get_child(max(0, index - 1)).get_path());
	set_focus_neighbor(SIDE_BOTTOM, p.get_child(min(index + 1, p.get_child_count() - 1)).get_path());
	
	mouse_filter = MOUSE_FILTER_IGNORE;

