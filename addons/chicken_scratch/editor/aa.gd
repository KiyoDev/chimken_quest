@tool
class_name x extends MarginContainer


signal go_next

signal text_stopped

signal finished_revealing

@export var container : Container
@export var Background : NinePatchRect
@export var TextBox : RichTextLabel
@export var indicator : Sprite2D
@export var indicator_animator : AnimationPlayer
@export var response_box : ResponseBox

var delay := 0.05

var revealing_text := false
var reveal_all := false
var killed := false


func _ready():
	hide_indicator()
	response_box.hide()
#	ChickenScratch.dialogue_finished.connect(_on_dialogue_finished)


func _exit_tree():
	pass


func response_index() -> int:
	return response_box.current_index


#func _connect_response(callable : Callable):
#	revealing_text = false
#	killed = false
#	reveal_all = false
#	hide_indicator()
#	response_box.hide()
#	response_box.selected.connect(callable)
#
#
#func _disconnect_response(callable : Callable):
#	revealing_text = false
#	killed = false
#	reveal_all = false
#	hide_indicator()
#	response_box.hide()
#	response_box.selected.disconnect(callable)


func clear():
	hide_indicator()
	TextBox.text = ""
	TextBox.visible_characters = 0
	ChickenScratch.Inputs.cancel_input.connect(_on_cancel_input)


func hide_indicator():
	indicator.hide()


func show_indicator():
	indicator_animator.play(&"idle")
	indicator.show()


# \n\n terminates line, stops and shows indicator
func load_dialogue(text : String, dialogue := {}):
	await get_tree().create_timer(0.001).timeout
	print_debug("box load_dialogue - %s" % [dialogue])
	killed = false
	reveal_all = false
	clear()
	indicator.position = Vector2i(container.size.x - 16, container.size.y - 10)
	
	var timer := Timer.new()
	add_child(timer)
	
	var line_num = 1
	for line in text.split("\n\n"):
		timer.wait_time = delay
		timer.start()
		print("%s: '%s'" % [line_num, line])
		TextBox.text = line
		TextBox.visible_characters = 0
		var len := TextBox.get_parsed_text().length()
		
		# Reveal text 1 character at a time w/ given delay
		for sec in range(0, len):
#			print("killed=%s, %s" % [killed, reveal_all])
			if(killed || reveal_all): break
			# TODO: if forward dialogue, reveal rest of text and break loop
			# if(forward): visible_characters = len; break
			
			TextBox.visible_characters += 1
#			print_debug("t: %s, '%s'" % [len, TextBox.get_parsed_text().substr(0, TextBox.visible_characters)])
			await timer.timeout
		
			timer.wait_time = delay
		
		timer.stop()
		show_indicator()
		await ChickenScratch.Inputs.input_action
		hide_indicator()
		
		print("\tdebug - %s" % [line])
		
		if(killed): break
		reveal_all = false
		line_num += 1
	
	print("finished")
	TextBox.visible_characters = 0
	timer.queue_free()
	finished_revealing.emit(dialogue)
	hide_indicator()
	killed = false
	reveal_all = false
	ChickenScratch.Inputs.cancel_input.disconnect(_on_cancel_input)
	

func open_response(responses : Array):
	response_box.open(responses)


## Force stop the dialogue
func kill():
	killed = true
	TextBox.visible_characters = TextBox.get_parsed_text().length()
	hide_indicator()


## Callback when Inputs receives cancel input. Reveals the remaining text and stops the current
func _on_cancel_input():
	print("cancel input")
	reveal_all = true
	TextBox.visible_characters = TextBox.get_parsed_text().length()
	hide_indicator()


func _on_resized():
#	print_debug("box rect - %s" % [size])
	indicator.position = Vector2i(container.size.x - 16, container.size.y - 10)


func _on_response_selected(node, index : int):
	pass
