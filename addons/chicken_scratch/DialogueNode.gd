@tool
class_name DialogueNode extends GraphNode


signal node_closed(node : DialogueNode);


@onready var Speaker : TextEdit = $VBoxContainer/Speaker;
@onready var Text : TextEdit = $VBoxContainer/Text;

@export var dialogue : Dialogue;


# Called when the node enters the scene tree for the first time.
func _ready():
	resize_request.connect(_on_resize_request);
	close_request.connect(_on_close_request);
	
	if(dialogue == null):
		dialogue = Dialogue.new();
	else:
		Speaker.text = dialogue.speaker;
		Text.text = dialogue.text;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resize_request(new_minsize : Vector2):
	custom_minimum_size = new_minsize;


func _on_close_request():
	# FIXME: add confirmation menu before actually deleting
	print_debug("_on_close_request");
	node_closed.emit(self);
	queue_free();


func _clone(flags := 0b0111):
	var node := super.duplicate(flags);
	node.dialogue = dialogue.duplicate();
	return node;


func empty() -> DialogueNode:
	var node := super.duplicate(0b0111);
	node.dialogue = Dialogue.new();
	return node


func _on_speaker_text_changed():
	dialogue.speaker = Speaker.text;


func _on_dialogue_text_changed():
	dialogue.text = Text.text;



func _on_test_print_pressed():
	print_debug("%s=[%s: '%s']" % [name, Speaker.text, Text.text]);


func _on_dragged(from, to):
	print_debug("dragging '%s' [%s->%s] %s" % [name, from, to, position]);
