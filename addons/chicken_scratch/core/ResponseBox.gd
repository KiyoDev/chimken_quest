@tool
class_name ResponseBox extends MarginContainer


signal selected(node, index)


enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}


@onready var background : NinePatchRect = $Background
@onready var responses : VBoxContainer = $MarginContainer/Responses
@onready var cursor : SelectCursor = $SelectCursor

@onready var response_label_scn : PackedScene = preload("res://addons/chicken_scratch/core/response_label.tscn")


var current_index := 0
var selecting := false

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("response box ready")
	cursor.start()
	cursor.hide()
	
	ChickenScratch.Inputs.input_up.connect(_on_input_up)
	ChickenScratch.Inputs.input_down.connect(_on_input_down)
	ChickenScratch.Inputs.accept_response.connect(_on_acccept_response)
	print(ChickenScratch.Inputs.input_up.get_connections())


func _exit_tree():
	if(ChickenScratch.Inputs.input_up.is_connected(_on_input_up)):
		ChickenScratch.Inputs.input_up.disconnect(_on_input_up)
		ChickenScratch.Inputs.input_down.disconnect(_on_input_down)
		ChickenScratch.Inputs.accept_response.disconnect(_on_acccept_response)
	

func open(responses : Array):
	print("resopnjses - %s" % [responses])
	selecting = true
	show()
	clear()
	for response in responses:
		add_response_label(response.text)
	await get_tree().create_timer(0.001).timeout
	focus(current_index)


func clear():
	for response in responses.get_children():
		response.queue_free()
	cursor.reparent(self)


func select():
	if(current_index < 0):
		push_error("Cursor index is negative")
		return
	
	ChickenScratch.Inputs.input_up.disconnect(_on_input_up)
	ChickenScratch.Inputs.input_down.disconnect(_on_input_down)
	ChickenScratch.Inputs.accept_response.disconnect(_on_acccept_response)
	
	selected.emit(responses.get_child(current_index), current_index)
	
	for response in responses.get_children():
		response.queue_free()
		
	selecting = false
	cursor.hide()
	clear()
	hide()


func navigate(direction : Direction) -> int:
	print_debug("navigate[%s]" % [direction])
	var count := responses.get_child_count()
	if(direction == Direction.UP || direction == Direction.DOWN):
		return (current_index + 1) % count if Direction.UP else (current_index - 1 + count) % count
	
	return 0


## Focus the next response
func focus(next : int):
	unfocus(current_index)
	
	var next_response : RichTextLabel = responses.get_child(next)
	print("next response(%s->%s)=%s" % [current_index, next, next_response])
	next_response.set_theme(load("res://addons/chicken_scratch/theme/white_font_small_outline.theme"))
	next_response.add_theme_color_override("font_shadow_color", Color(0, 0, 1, 0.40))
	var highlighted := "[wave][rainbow]%s[/rainbow][/wave]" % [next_response.text]
	next_response.text = ""
	(next_response as RichTextLabel).append_text(highlighted)
	print("next - %s, %s" % [next_response.bbcode_enabled, next_response.text])
	
	cursor.show()
	cursor.update_pos(next_response)
#	cursor.reparent(self)
	current_index = next


func unfocus(index : int):
	var next_response : RichTextLabel = responses.get_child(index)
	next_response.set_theme(load("res://addons/chicken_scratch/theme/black_font_small.theme"))
	next_response.remove_theme_color_override("font_shadow_color")
	next_response.text = next_response.get_parsed_text()


func add_response_label(text : String):
	var label : RichTextLabel = response_label_scn.instantiate()
	responses.add_child(label)
#	label.selection_enabled = true
#	label.clip_contents = false
#	label.autowrap_mode = TextServer.AUTOWRAP_OFF
#	label.fit_content = true
#	label.bbcode_enabled = true
	label.text = text


func _on_input_up():
	print_debug("input up")
	var next := navigate(Direction.UP)
	if(next == current_index): return
	focus(next)
	

func _on_input_down():
	print_debug("input down")
	var next := navigate(Direction.DOWN)
	if(next == current_index): return
	focus(next)
	

func _on_acccept_response():
	print_debug("accept response")
	select()


func _on_response_close():
	clear()
	hide()
