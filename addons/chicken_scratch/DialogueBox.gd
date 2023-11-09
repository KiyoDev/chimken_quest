@tool
class_name DialogueBox extends MarginContainer


signal next_pressed;

signal text_stopped;

signal dialogue_finished;


@export var Background : NinePatchRect;
@export var TextBox : RichTextLabel;
@export var indicator : Sprite2D;
@export var indicator_animator : AnimationPlayer;

@export var text_speed := 0.04;


var tween : Tween;

var tween_finished := false;


func _ready():
	tween_finished = false;
	indicator.hide();


func _input(event):
	if(tween_finished && (event.is_action_pressed(&"ui_accept") || event.is_action_pressed(&"ui_cancel"))):
		print_debug("DialogueBox input - %s" % [event]);
		tween_finished = false;
		indicator_animator.stop();
		indicator.hide();
		next_pressed.emit();
	elif(tween.is_running() && event.is_action_pressed(&"ui_cancel")):
		show_indicator();
		tween_finished = true;
		TextBox.visible_ratio = 1;
		tween.stop();


func show_indicator():
	indicator_animator.play(&"idle");
	indicator.show();


# \n terminates line, stops and shows indicator
func load_dialogue(text : String):
	await get_tree().create_timer(0.001).timeout;
	print_debug("box rect - %s" % [size]);
	indicator.position = Vector2i(size.x - 16, size.y - 10);
	
	var line_num = 1;
	for line in text.split("\n"):
		tween = create_tween();
		tween.stop();
		tween.finished.connect(_on_tween_finished);
		print("%s: '%s'" % [line_num, line]);
		TextBox.text = line;
		TextBox.visible_characters = 0;
		var len := TextBox.get_parsed_text().length();
		
		tween.tween_property(TextBox, "visible_characters", len, text_speed * len);

		tween.play();
		
		await next_pressed;
		line_num += 1;
	
	dialogue_finished.emit(self);


func _on_tween_finished():
	print_debug("tween finished");
	show_indicator();
	tween_finished = true;


func _on_text_resized():
	print_debug("box rect - %s" % [size]);
	indicator.position = Vector2i(size.x - 16, size.y - 10);