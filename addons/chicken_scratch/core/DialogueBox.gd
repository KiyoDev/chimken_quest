@tool
class_name DialogueBox extends MarginContainer


signal go_next

signal text_stopped

signal dialogue_finished


@export var Background : NinePatchRect
@export var TextBox : RichTextLabel
@export var indicator : Sprite2D
@export var indicator_animator : AnimationPlayer

var text_speed := 0.04

var revealing_text := false

var tween : Tween

var tween_finished := false


func _ready():
	tween_finished = false
	indicator.hide()


func _exit_tree():
	if(tween != null):
		tween.stop()


#func _input(event):
#	if(tween == null): return
#
#	if(tween_finished && (event.is_action_pressed(&"ui_accept") || event.is_action_pressed(&"ui_cancel"))):
#		print_debug("DialogueBox input - %s" % [event])
#		tween_finished = false
#		indicator_animator.stop()
#		indicator.hide()
#		go_next.emit(true)
#	elif(tween.is_running() && event.is_action_pressed(&"ui_cancel")):
#		show_indicator()
#		tween.stop()
#		tween_finished = true
#		TextBox.visible_ratio = 1


#func restart():
#	go_next.emit(false)
#	if(tween):
#		print_debug("cancel dialogue")
#		tween.finished.disconnect(_on_tween_finished)
#		tween.kill()
#	tween_finished = false
#	indicator_animator.stop()
#	indicator.hide()




func show_indicator():
	indicator_animator.play(&"idle")
	indicator.show()


# \n terminates line, stops and shows indicator
func load_dialogue(text : String, dialogue := {}):
	tween_finished = false
	await get_tree().create_timer(0.001).timeout
#	print_debug("box rect - %s" % [size])
	indicator.position = Vector2i(size.x - 16, size.y - 10)
	
	var line_num = 1
	for line in text.split("\n"):
		tween = create_tween()
		tween.stop()
		tween.finished.connect(_on_tween_finished.bind(line))
		print("%s: '%s'" % [line_num, line])
		TextBox.text = line
		TextBox.visible_characters = 0
		var len := TextBox.get_parsed_text().length()
		
		tween.tween_property(TextBox, "visible_characters", len, text_speed * len)
		tween.play()
		
		var continue_dialogue = await go_next
		print("\tdebug - %s" % [line])
		if(!continue_dialogue): 
			print_debug("do not continue - %s" % [line])
#			restart()
			return
		line_num += 1
	
	dialogue_finished.emit(dialogue)


func _on_tween_finished(line : String):
	if(tween_finished):
		print_debug("tween finished but already finished - %s" % [line])
#		restart()
		return
	print_debug("tween finished - %s, %s" % [tween_finished, line])
	show_indicator()
	tween_finished = true


func _on_resized():
#	print_debug("box rect - %s" % [size])
	indicator.position = Vector2i(size.x - 16, size.y - 10)
