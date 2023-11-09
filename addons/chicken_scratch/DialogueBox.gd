@tool
class_name DialogueBox extends MarginContainer


signal next_pressed;

signal text_stopped;

signal dialogue_finished;


@export var Background : NinePatchRect;
@export var TextBox : RichTextLabel;
@export var indicator : Sprite2D;
@export var indicator_animator : AnimationPlayer;

@export var text_speed := 0.05;


var tween : Tween;

var tween_finished := false;


func _ready():
	tween_finished = false;
	indicator.hide();
	
	var end := get_rect().end;
	indicator.position = Vector2i(end.x - 24, end.y - 6);
	indicator_animator.play(&"idle");


func _input(event):
	if(tween_finished && (event.is_action_pressed(&"ui_accept") || event.is_action_pressed(&"ui_cancel"))):
		print_debug("DialogueBox input - %s" % [event]);
		tween_finished = false;
		indicator.hide();
		next_pressed.emit();
	elif(tween.is_running() && event.is_action_pressed(&"ui_cancel")):
		indicator.show();
		tween_finished = true;
		TextBox.visible_ratio = 1;
		tween.stop();


# \n terminates line, stops and shows indicator
func load_dialogue(text : String):
	var line_num = 1;
	for line in text.split("\n"):
		tween = create_tween();
		tween.stop();
		tween.finished.connect(_on_tween_finished);
		print("%s: '%s'" % [line_num, line]);
		TextBox.text = line;
		TextBox.visible_characters = 0;
		var len := TextBox.get_parsed_text().length();
		
		tween.tween_property(TextBox, "visible_characters", len, 0.05 * len);

		tween.play();
		
		await next_pressed;
		line_num += 1;
	
	dialogue_finished.emit(self);


func _on_tween_finished():
	print_debug("tween finished");
	indicator.show();
	tween_finished = true;
