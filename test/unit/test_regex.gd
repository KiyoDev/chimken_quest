extends GutTest


const variable_pattern := "\\${\\s*\\K(?<var>[a-zA-Z_]+[a-zA-Z0-9_]*(\\.[a-zA-Z0-9_]+)*)(?<params>\\(\\s*(?<param>(\\${\\s*[a-zA-Z_]+[a-zA-Z0-9_]*(\\.[a-zA-Z0-9_]+)*\\s*})|('[^'\"]*')|((true)|(false))|(?<int>[0-9]+[0-9_]*)|((?&int)\\.(?&int)))(\\s*,\\s*(?&param)\\s*)*\\))?(?=\\s*})"

const params_pattern := ",?\\s*\\K(?<bool>(true)|(false))|(?<float>\\d+\\.\\d+)|(?<int>(?:(?<!\\.)\\d(?!\\.))+)|(?<string>(?<=')[^'\"]*(?='))|(?<variable>(?<=\\${)\\s*\\K[a-zA-Z_]+[a-zA-Z0-9_]*(\\.[a-zA-Z_]+[a-zA-Z0-9_]*)*(?=\\s*}))"
	
func test_variable_regex():
	print("Testing regex")
	var var_regex := RegEx.create_from_string(variable_pattern)
	var params_regex := RegEx.create_from_string(params_pattern)
	
	var text := "Other fluff ${ Autoload.testing.method(1, true , 12924, 1.4239234, '!#:$%<1 [l;fi-k1,!>#F]',${ graph_value    }, ${ Autoload.nested_value } ) } KALDJ${Autoload.normal_value}HGK:ALDJG 9023u50piojadf0 ji@%:#: 1';45 ${Autoload.other_method('parameter', true, 1, 6.9, ${Autoload.nested_value})  }"
	
	var results := var_regex.search_all(text)
	
	for found in results:
		var variable_string := found.get_string("var")
		print("found=\"%s\"" % [variable_string])
		# check here if this variable_string is a method. if so look for "params"
		
		var params := found.get_string("params")
		print("parameters=\"%s\"" % [params])
		
		for param in params_regex.search_all(params):
			if(!param.get_string("float").is_empty()):
				print("-- float=\"%s\"" % [param.get_string()])
			elif(!param.get_string("int").is_empty()):
				print("-- int=\"%s\"" % [param.get_string()])
			elif(!param.get_string("bool").is_empty()): 
				print("-- bool=\"%s\"" % [param.get_string()])
			elif(!param.get_string("variable").is_empty()): 
				print("-- variable=\"%s\"" % [param.get_string()])
			elif(param.get_string("string")):
				print("-- string=\"%s\"" % [param.get_string()])
		# parse params here
