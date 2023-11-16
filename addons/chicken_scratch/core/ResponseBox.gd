@tool
class_name ResponseBox extends MarginContainer


signal selected(node, index)


enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}


@export var background : NinePatchRect
@export var responses : VBoxContainer
@export var cursor : Node2D

@export var response_label_scn : PackedScene


var current_index := 0
var selecting := false

# Called when the node enters the scene tree for the first time.
func _ready():
	cursor.find_child("AnimationPlayer").play("moving")
	cursor.hide()


func open(responses : Array):
	print("resopnjses - %s" % [responses])
	selecting = true
	show()
	clear()
	for response in responses:
		add_response_label(response.text)
	focus(current_index)

func clear():
	for response in responses.get_children():
		response.queue_free()
	cursor.reparent(self)


func select():
	if(current_index < 0):
		push_error("Cursor index is negative")
		return
	
	selecting = false
	cursor.hide()
	selected.emit(responses.get_child(current_index), current_index)
	clear()
	hide()


func _input(event):
	if(!selecting): return
	if(event is InputEventAction):
		print_debug("response box input")
		if(event.is_action_pressed(&"ui_up")):
			var next := navigate(Direction.UP)
			if(next == current_index): return
			focus(next)
		elif(event.is_action_pressed(&"ui_down")):
			var next := navigate(Direction.DOWN)
			if(next == current_index): return
			focus(next)
		elif(event.is_action_pressed(&"ui_accept")):
			select()
		
#try_get_option(clampi(focused_index + move.y, 0, option_count() - 1));


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
	next_response.add_theme_color_override("font_shadow_color", Color.BLACK)
	var highlighted := "[wave][rainbow]%s[/rainbow][/wave]" % [next_response.text]
	next_response.text = highlighted
	(next_response as RichTextLabel).append_text(highlighted)
#	(next_response as RichTextLabel).
	print("next - %s, %s" % [next_response.bbcode_enabled, next_response.text])
	
	cursor.show()
#	cursor.reparent(self)
	update_cursor_pos(next_response)
	current_index = next
	



func unfocus(index : int):
	var next_response : RichTextLabel = responses.get_child(index)
	next_response.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	next_response.text = next_response.get_parsed_text()
	


func update_cursor_pos(label : RichTextLabel):
#	print_debug("updating cursor pos - [%s, %s]" % [global_position, option.global_position]);
	cursor.global_position = Vector2(label.global_position.x - 5, label.global_position.y );


func add_response_label(text : String):
	var label : RichTextLabel = response_label_scn.instantiate()
	responses.add_child(label)
#	label.selection_enabled = true
#	label.clip_contents = false
#	label.autowrap_mode = TextServer.AUTOWRAP_OFF
#	label.fit_content = true
#	label.bbcode_enabled = true
	label.text = text


func _on_response_close():
	clear()
	hide()
