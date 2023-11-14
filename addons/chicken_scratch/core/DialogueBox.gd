@tool
class_name DialogueBox extends MarginContainer


signal go_next

signal text_stopped

signal finished_revealing


@export var Background : NinePatchRect
@export var TextBox : RichTextLabel
@export var indicator : Sprite2D
@export var indicator_animator : AnimationPlayer

var delay := 0.05

var revealing_text := false

var killed := false

func _ready():
	hide_indicator()
#	ChickenScratch.dialogue_finished.connect(_on_dialogue_finished)


func _exit_tree():
	pass


#func restart():
#	go_next.emit(false)
#	if(tween):
#		print_debug("cancel dialogue")
#		tween.finished.disconnect(_on_tween_finished)
#		tween.kill()
#	tween_finished = false
#	indicator_animator.stop()
#	indicator.hide()


func clear():
	hide_indicator()
	TextBox.text = ""
	TextBox.visible_characters = 0


func hide_indicator():
	indicator.hide()


func show_indicator():
	indicator_animator.play(&"idle")
	indicator.show()


# \n terminates line, stops and shows indicator
func load_dialogue(text : String, dialogue := {}):
#	await get_tree().create_timer(0.001).timeout
#	print_debug("box rect - %s" % [size])
	killed = false
	clear()
	indicator.position = Vector2i(size.x - 16, size.y - 10)
	
	var timer := Timer.new()
	timer.wait_time = delay
	add_child(timer)
	timer.start()
	
	var line_num = 1
	for line in text.split("\n\n"):
		print("%s: '%s'" % [line_num, line])
		TextBox.text = line
		TextBox.visible_characters = 0
		var len := TextBox.get_parsed_text().length()
		
#		tween.tween_property(TextBox, "visible_characters", len, delay * len)
#		tween.play()
		
		for sec in range(0, len):
			print("killed=%s" % [killed])
			if(killed): break
			# TODO: if forward dialogue, reveal rest of text and break loop
			# if(forward): visible_characters = len; break
			
			TextBox.visible_characters += 1
			print("t: '%s'" % [TextBox.get_parsed_text().substr(0, TextBox.visible_characters)])
			await timer.timeout
		
			timer.wait_time = delay
		
		timer.stop()
		show_indicator()
#		print("aa - %s" % [ChickenScratch.Inputs.has_signal("input_action")])
		await ChickenScratch.Inputs.input_action
		# TODO: show indicator, wait for input 
		
#		var continue_dialogue = await go_next
		print("\tdebug - %s" % [line])
#		if(!continue_dialogue): 
#			print_debug("do not continue - %s" % [line])
##			restart()
#			return
		if(killed): break
		line_num += 1
#	for line in text.split("\n"):
#		tween = create_tween()
#		tween.stop()
#		tween.finished.connect(_on_tween_finished.bind(line))
#		print("%s: '%s'" % [line_num, line])
#		TextBox.text = line
#		TextBox.visible_characters = 0
#		var len := TextBox.get_parsed_text().length()
#
#		tween.tween_property(TextBox, "visible_characters", len, delay * len)
#		tween.play()
	print("finished")
	TextBox.visible_characters = 0
	timer.queue_free()
	finished_revealing.emit(dialogue)
	hide_indicator()
	killed = false


#func _on_tween_finished(line : String):
#	if(tween_finished):
#		print_debug("tween finished but already finished - %s" % [line])
##		restart()
#		return
#	print_debug("tween finished - %s, %s" % [tween_finished, line])
#	show_indicator()
#	tween_finished = true

func kill():
	killed = true
	TextBox.visible_characters = TextBox.get_parsed_text().length()
	hide_indicator()


func _on_resized():
#	print_debug("box rect - %s" % [size])
	indicator.position = Vector2i(size.x - 16, size.y - 10)
