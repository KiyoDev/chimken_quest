class_name IntLabel extends Label


var regex = RegEx.new();
var oldtext = "";


func _ready():
	regex.compile("^[0-9]*$");
	gui_input.connect(_on_LineEdit_text_changed);


func _on_LineEdit_text_changed(new_text):
	print("lkadjgkladgja");
	if regex.search(new_text):
		oldtext = new_text;
		text = new_text;
	else:
		text = oldtext;
#    set_cursor_position(text.length())


func get_value():
	return(int(text));
