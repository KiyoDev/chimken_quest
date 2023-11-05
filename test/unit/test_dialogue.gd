extends GutTest 


func test_variable_regex():
	var variable_match = RegEx.new()
	variable_match.compile("\\${\\w+}");
	var yes = variable_match.search_all("Hello ${bobby}, ${}, how are ${yo__u}, ${af{af}}");
	
	for found in yes:
		print("match - %s" % [found.get_string()]);
		
	assert_eq(yes.size(), 2);
	assert_eq(variable_match.search_all("${af{af}}").size(), 0);

#	var variable_wrong = RegEx.new()
#	variable_wrong.compile("\\${/(\\w*)(?!\\1)(\\W+)(\\1\\2)+/}");
##	variable_wrong.compile("\\${\\w*\\W+\\w*\\W*\\w*}");
#	var ehh = variable_wrong.search_all("Hello ${bobby}, ${}, how are ${yo__u}, ${asdf{fasdf}asdf}");
#
#	for found in ehh:
#		print("ehh - %s" % [found.get_string()]);
