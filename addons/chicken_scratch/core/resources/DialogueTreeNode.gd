class_name DialogueTreeNode extends TreeNode


enum DialogueType {
	DIALOGUE,
	OFFERING,
	RESPONSE
}


var type := DialogueType.DIALOGUE

var speaker := ""

var text := ""

var next := {}


func node_type():
	return NodeType.Dialogue


func get_next(next_index := 0):
	match(type):
		DialogueType.DIALOGUE:
			return next.get(0, null)
		DialogueType.OFFERING:
			pass
		DialogueType.RESPONSE:
			pass 
	
	pass
