@tool
class_name DialogueEditHighlighter extends SyntaxHighlighter
#class_name DialogueEditHighlighter extends CodeHighlighter

var variable_match : RegEx;
var text_edit : TextEdit;

var variable_color := Color("ee82ee");


func _init():
#	number_color = Color("86d2ba");
#	symbol_color = Color("e39f6a");
	variable_match = RegEx.create_from_string("\\${\\w+}");
	pass;


func _get_line_syntax_highlighting(line_number : int):
#	super.get_line_syntax_highlighting(line);
	if(text_edit == null):
		text_edit = get_text_edit();
#	print("text edit %s" % text_edit);

	var line := text_edit.get_line(line_number);
	
	var found := variable_match.search_all(line);
	
	var cols := {};
	
	for l in found:
		print(l.get_start());
		print(l.get_string());
		cols[l.get_start()] = {"color":variable_color};
		cols[l.get_end()] = {};
	
	print("line[%s]=%s" % [line_number, line]);
	
	return cols;
