class_name ClampCamera extends Camera2D

# TODO: make sure level has a collision shape in group for level bounds
@onready var AreaBounds : CollisionShape2D = get_tree().get_first_node_in_group("Bounds");


# Called when the node enters the scene tree for the first time.
func _ready():
	if(AreaBounds == null): return;
	set_scroll_limits(AreaBounds);
	var t : TileMap = get_tree().get_first_node_in_group("TileMap");
	
	print("t.get_used_rect() - %s" % [t.get_used_rect()]);


func set_scroll_limits(coll : CollisionShape2D):
	var rect := coll.shape.get_rect();
	var h_dia := rect.size.y / 2;
	var w_dia := rect.size.x / 2;
	
	var top := coll.position.y - h_dia;
	var bottom := coll.position.y + h_dia;
	var left := coll.position.x - w_dia;
	var right := coll.position.x + w_dia;
	
	print("[%s, %s, %s, %s]" % [top, bottom, left, right]);
	print("area - %s, %s" % [rect.position, coll.position]);
	
	limit_top = top;
	limit_bottom = bottom;
	limit_left = left;
	limit_right = right;

 
