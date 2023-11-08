@tool
class_name DialogueEditHighlighter extends SyntaxHighlighter


const VARIABLE_PATTERN := "\\${[a-zA-Z_]+[\\w]*}";
const BINARY_PATTERN := "0b([01]+_?)+";
const HEX_PATTERN := "0x([0-9a-fA-F]+_?)+";
const NUMBER_PATTERN := "([0-9]+\\.[0-9]+)|(([0-9]+_?)+)";
const SYMBOL_PATTERN := "[`~@#$%^&*()+\\[\\]\\-=\\{}|;\':\"<>]+";


var variable_match : RegEx;
var binary_match : RegEx;
var hex_match : RegEx;
var number_match : RegEx;
var symbol_match : RegEx;
var text_edit : TextEdit;

@export var variable_color := Color("ee82ee");
@export var binary_color := Color("2c5bf5");
@export var hex_color := Color("6d49f2");
@export var number_color = Color("86d3bb");
@export var symbol_color = Color("f2a96f");

var line_cache := {};
var highlight_cache := {};

func _init():
	variable_match = RegEx.create_from_string(VARIABLE_PATTERN);
	binary_match = RegEx.create_from_string(BINARY_PATTERN);
	hex_match = RegEx.create_from_string(HEX_PATTERN);
	number_match = RegEx.create_from_string(NUMBER_PATTERN);
	symbol_match = RegEx.create_from_string(SYMBOL_PATTERN);

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
	
#	print("line[%s]=%s" % [line_number, line]);
	
	var color_ranges := {};
	
	# variable search
	var v_found := variable_match.search_all(line);
	for l in v_found:
		var start := l.get_start();
		var end := l.get_end();
		var str := l.get_string();
		
		color_ranges[start] = end;
		cols[start] = {"color":variable_color};
		if(end < line.length()):
			cols[end] = {};
		
#		print("l - (%s, %s), %s, %s" % [start, end, str, cols]);

#	print("color_ranges - %s" % [color_ranges]);
	# binary number search
	var b_found := binary_match.search_all(line);
	for b in b_found:
		var start := b.get_start();
		var end := b.get_end();
		var str := b.get_string();
		var after_range_end := start_in_range(start, color_ranges);
		var before_range_start := end_in_range(end, color_ranges);

#		print("b - %s, %s" % [start, str]);
		if((after_range_end == -1 && !cols.has(start)) || (cols.has(start) && cols[start].is_empty())):
			cols[start] = {"color":binary_color};
			if(!cols.has(end) && before_range_start == -1):
				cols[end] = {};
				color_ranges[start] = end;
			elif(before_range_start > -1):
				color_ranges[start] = before_range_start;
				
	# hex number search
	var h_found := hex_match.search_all(line);
	for h in h_found:
		var start := h.get_start();
		var end := h.get_end();
		var str := h.get_string();
		var after_range_end := start_in_range(start, color_ranges);
		var before_range_start := end_in_range(end, color_ranges);

#		print("h - %s, %s" % [start, str]);
		if((after_range_end == -1 && !cols.has(start)) || (cols.has(start) && cols[start].is_empty())):
			cols[start] = {"color":hex_color};
			if(!cols.has(end) && before_range_start == -1):
				cols[end] = {};
				color_ranges[start] = end;
			elif(before_range_start > -1):
				color_ranges[start] = before_range_start;
				
	# number search
	var n_found := number_match.search_all(line);
	for n in n_found:
		var start := n.get_start();
		var end := n.get_end();
		var str := n.get_string();
		var after_range_end := start_in_range(start, color_ranges);
		var before_range_start := end_in_range(end, color_ranges);

#		print("n - %s, %s" % [start, str]);
		if((after_range_end == -1 && !cols.has(start)) || (cols.has(start) && cols[start].is_empty())):
			cols[start] = {"color":number_color};
			if(!cols.has(end) && before_range_start == -1):
				cols[end] = {};
	
	var s_found := symbol_match.search_all(line);
	for s in s_found:
		var start := s.get_start();
		var end := s.get_end();
		var str := s.get_string();
		var start_in_range := in_variable_range(start, color_ranges);
		var end_in_range := in_variable_range(end, color_ranges);
#		print("s - %s, %s" % [start, str]);

		if((!start_in_range && !cols.has(start)) || (cols.has(start) && cols[start].is_empty())):
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

#	print("out %s" % [out]);
	
	return out;


func in_variable_range(num : int, color_ranges : Dictionary) -> bool:
	var in_range := false;
	
	for r in color_ranges:
		if(r <= num && num <= color_ranges[r]):
			in_range = true;
			break;

	return in_range;


func start_in_range(start : int, color_ranges : Dictionary) -> int:
	var index := -1;
	
	for r in color_ranges:
		if(r <= start && start <= color_ranges[r]):
			index = color_ranges[r];
			break;

	return index;


func end_in_range(end : int, color_ranges : Dictionary) -> int:
	var index := -1;
	
	for r in color_ranges:
		if(r <= end && end <= color_ranges[r]):
			index = r;
			break;

	return index;
