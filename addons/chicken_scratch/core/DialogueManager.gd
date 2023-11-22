@tool
extends Node


signal offering_submitted

signal response_chosen

signal dialogue_paused

signal dialogue_resumed

signal dialogue_started

signal dialogue_finished

signal variables_updated


enum Type {
	Dialogue,
	Offering,
	Response
}


@export var dialogue_box : Node

var VariableHandler : DialogueVariableHandler
var Inputs : DialogueInputHandler

var variables := {} # { "name": <value> }

var dialogue_tree : DialogueTree

var playing := false 


func _ready():
	# module stuff
	VariableHandler = DialogueVariableHandler.new()
	add_child(VariableHandler)
	
	Inputs = DialogueInputHandler.new()
	Inputs.name = "Input"
	add_child(Inputs)
	
	Inputs.set_process_input(false)
	
	print("VariableHandler %s" % [Inputs])
#	print("InputHandler %s" % [ChickenScratch.Input])
	print("Inputs %s" % [ChickenScratch.Inputs])


func update_variable_name(old : String, new : Variant):
	print_debug("'%s'->: %s" % [old, variables.get(old)])
	var value = variables.get(old)
	variables.erase(old)
	variables[new] = value
	dialogue_tree.variables.erase(old)
	dialogue_tree.variables[new] = value
	print_debug("  ->'%s': %s" % [new, variables.get(new)])
	variables_updated.emit()


func update_variable_value(name : String, value : Variant):
	variables[name] = value
	dialogue_tree.variables[name] = value
	variables_updated.emit()
	

func delete_variable(name : String):
	variables.erase(name)
	dialogue_tree.variables.erase(name)
	variables_updated.emit()


func preload_tree(path : String, dialogue_box : Node):
	print("preload tree - %s" % [path])
	if path.begins_with("res://"):
		print_debug("??? - %s, %s" % [path.to_lower().ends_with(".dngraph"), path.to_lower().ends_with(".json")])
		if(path.to_lower().ends_with(".dngraph") || path.to_lower().ends_with(".json")):
			dialogue_tree = DialogueTree.new()
			dialogue_tree.open_from_path(path)
			
			variables = dialogue_tree.variables
			print("dialogue_tree - %s" % [dialogue_tree.nodes])
		elif(path.to_lower().ends_with(".tres") || path.to_lower().ends_with(".res")):
			dialogue_tree = load(path)
		
		self.dialogue_box = dialogue_box


func reset():
	playing = false


func stop():
	playing = false
	dialogue_finished.emit()


func kill():
	playing = false
	dialogue_box.kill()
	dialogue_finished.emit()


func play():
	if(playing): 
		push_warning("Dialogue already playing...")
		return
	playing = true
	Inputs.set_process_input(true)
	var root = dialogue_tree.root_node
	
	await load_next_dialogue(root.name, 0)
	
	dialogue_finished.emit()
	playing = false


func play_branch(slot : int):
	if(playing): 
		push_warning("Dialogue already playing...")
		return
	playing = true
	Inputs.set_process_input(true)
	var root = dialogue_tree.root_node
	
	await load_next_dialogue(root.name, slot)
	print("#play_branch[%s] finished" % [slot])
	
	dialogue_finished.emit()
	playing = false


func play_at(name : String):
	if(playing): 
		push_warning("Dialogue already playing...")
		return
	playing = true
	Inputs.set_process_input(true)
	
	await load_dialogue(dialogue_tree.nodes[name])
	print("#play_at[%s] finished" % [name])
	
	dialogue_finished.emit()
	playing = false


func play_text(dialogue : Dictionary):
	if(playing): 
		push_warning("Dialogue already playing...")
		return
	playing = true
	Inputs.set_process_input(true)
	
#	await load_dialogue(dialogue)
	var type : Type = Type[dialogue.type] # type name -> enum
	var speaker : String = dialogue.speaker
	var text : String = dialogue.text
#	print_debug("loading dialogue - %s" % [variables])
	
	# TODO: 
	match(type):
		Type.Dialogue:
			pass
		Type.Offering:
			pass
		Type.Response:
			pass
	
	var parsed := VariableHandler.parse_text(text)
	print_debug("# parsed %s" % [parsed])
	
#	DialogueInputHandler.accept_input.connect()
	await dialogue_box.load_dialogue(parsed, dialogue)
	print_debug("# dialogue_box finished")
	print("#play_text[%s] finished" % [name])
	
	dialogue_finished.emit()
	playing = false


# TODO: implement displaying dialogue boxes at a position (based off of Character); when switching speakers, animate dialogue box close and open at next speakers location


## Load dialogue from a dictionary
func load_dialogue(dialogue : Dictionary):
	Inputs.focused = DialogueInputHandler.Focused.DIALOGUE_BOX
	# get dialogue info from dictionary
	print("# dialogue - %s" % [dialogue])
	var type : Type = Type[dialogue.type] # type name -> enum
	var speaker : String = dialogue.speaker
	var text : String = dialogue.text
#	print_debug("loading dialogue - %s" % [variables])
	
	# TODO: 
	match(type):
		Type.Dialogue:
			pass
		Type.Offering:
			pass
		Type.Response:
			pass
	
	var parsed := VariableHandler.parse_text(text)
	print_debug("# parsed %s" % [parsed])
	
#	DialogueInputHandler.accept_input.connect()
	await dialogue_box.load_dialogue(parsed, dialogue)
	print_debug("# dialogue_box finished")
	
	return await try_move_next(dialogue)


## Tries to advance dialogue to the next available dialogue option
func try_move_next(dialogue : Dictionary) -> bool:
	print_debug("## dialogue finished, try to move on to next.")
	var type : Type = Type[dialogue.type] # type name -> enum
	var speaker : String = dialogue.speaker
	var text : String = dialogue.text
#	print_debug("loading dialogue - %s" % [variables])
	
	# TODO: do different things depending on the dialogue type;
	match(type):
		Type.Dialogue:
			print_debug("## current is dialogue, go to slot 0")
			return await load_next_dialogue(dialogue.name, 0)
		Type.Offering:
			# TODO: bring up a menu to choose items from inventory to offer
			print_debug("## current is offering, bring up offering")
			return await load_next_dialogue(dialogue.name, 0)
#			await offering_submitted
		Type.Response:
			# TODO: bring up a menu to choose responses
			print_debug("## current is response, go to slot of the chosen response")
			Inputs.focused = DialogueInputHandler.Focused.RESPONSE_BOX
			dialogue_box.open_response(dialogue.properties.responses)
			await dialogue_box.response_box.selected
			Inputs.focused = DialogueInputHandler.Focused.DIALOGUE_BOX
			return await load_next_dialogue(dialogue.name, dialogue_box.response_index())
#			await response_chosen
	return false
	

## Tries to load the dialogue with the given name
func load_next_dialogue(name : String, slot) -> bool:
	slot = str(slot)
	print("### next - %s, %s" % [name, slot])
	print("### conn - %s, %s" % [dialogue_tree.connections, dialogue_tree.connections.has(name)])
#	print("conn - %s, %s, %s" % [dialogue_tree.connections, dialogue_tree.connections.has(name), dialogue_tree.connections[name].has(slot)])
	
	if(dialogue_tree.connections.has(name) && dialogue_tree.connections[name].has(slot)):
		var next = dialogue_tree.connections[name][slot]
		print("### connections[next] %s" % [next])
		await load_dialogue(dialogue_tree.nodes[next.to])
		print("### finished loading next" )
		return true
	else:
		print_debug("No connections left")
		dialogue_finished.emit()
		return false


#func _on_response_selected(node, index : int):
#	dialogue_box.response_box.selected.disconnect(_on_response_selected)
