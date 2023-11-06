@tool
class_name DialogueEditHighlighter extends CodeHighlighter
#class_name DialogueEditHighlighter extends CodeHighlighter

var variable_match : RegEx;
var number_match : RegEx;
var symbol_match : RegEx;
var text_edit : TextEdit;

var variable_color := Color("ee82ee");

var line_cache := {};
var highlight_cache := {};

func _init():
	variable_match = RegEx.create_from_string("\\${[a-zA-Z_]+}");
	number_match = RegEx.create_from_string("(0b[01_]+)|(0x([a-fA-F0-9]+)|[a-fA-F0-9_]+_[a-fA-F0-9_]+)|(([0-9]+)|[0-9]+_[0-9]+)");
	symbol_match = RegEx.create_from_string("[`~!@#$%^&*()+\\[\\]\\-=\\{}|;\':\",./<>?]+");
	number_color = Color("86d3bb");
	symbol_color = Color("f2a96f");


func _get_line_syntax_highlighting(line_number : int):
#	super.get_line_syntax_highlighting(line);
	if(text_edit == null):
		text_edit = get_text_edit();
#	print("text edit %s" % text_edit);

	var cols := {};
	var line := text_edit.get_line(line_number);
	
	if(line_cache.has(line_number) && line_cache[line_number] == line):
		return highlight_cache[line_number];
		
	line_cache[line_number] = line;
	
	print("line[%s]=%s" % [line_number, line]);
	
	var v_ranges := {};
	
	var v_found := variable_match.search_all(line);
	for l in v_found:
		var start := l.get_start();
		var end := l.get_end();
		var str := l.get_string();
		
		v_ranges[start] = end;
		cols[start] = {"color":variable_color};
		if(end < line.length() - 1):
			cols[end] = {};
		
		print("l - (%s, %s), %s, %s" % [start, end, str, cols]);

	print("v_ranges - %s" % [v_ranges]);
	
	var n_found := number_match.search_all(line);
	for n in n_found:
		var start := n.get_start();
		var end := n.get_end();
		var str := n.get_string();
		var start_in_range := in_variable_range(start, v_ranges);
		var end_in_range := in_variable_range(end, v_ranges);

		print("n - %s, %s" % [start, str]);
		if(!start_in_range && (!cols.has(start) || cols[start].is_empty())):
			cols[start] = {"color":number_color};
			if(!cols.has(end) && !end_in_range):
				cols[end] = {};
	
	var s_found := symbol_match.search_all(line);
	for s in s_found:
		var start := s.get_start();
		var end := s.get_end();
		var str := s.get_string();
		var start_in_range := in_variable_range(start, v_ranges);
		var end_in_range := in_variable_range(end, v_ranges);
		print("s - %s, %s" % [start, str]);
				
		if(!start_in_range && (!cols.has(start) || cols[start].is_empty())):
			cols[start] = {"color":symbol_color};
			if(!cols.has(end) && !end_in_range):
				cols[end] = {};
	
	# sort column numbers for proper highlighting order
	var to_sort := [];
	for k in cols:
		to_sort.append(k);
	to_sort.sort();
	
	var out := {};
	for num in to_sort:
		out[num] = cols[num];
	
	highlight_cache[line_number] = out;

	print("out %s" % [out]);
	
	return out;


func in_variable_range(num : int, v_ranges : Dictionary) -> bool:
	var in_range := false;
	
	for r in v_ranges:
		if(r <= num && num <= v_ranges[r]):
			in_range = true;
			break;

	return in_range;
