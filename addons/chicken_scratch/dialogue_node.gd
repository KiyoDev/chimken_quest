@tool
class_name DialogueNode extends GraphNode


# Called when the node enters the scene tree for the first time.
func _ready():
	resize_request.connect(on_resize_request);
	close_request.connect(on_close_request);
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_resize_request(new_minsize : Vector2):
	custom_minimum_size = new_minsize;


func on_close_request():
	queue_free();

