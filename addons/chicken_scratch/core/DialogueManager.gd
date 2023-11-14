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


@export var dialogue_box : DialogueBox

var VariableHandler : DialogueVariableHandler
var Inputs : DialogueInputHandler

var variables := {} # { "name": <value> }

var dialogue_tree : DialogueTree

var started := false 


func _ready():
	# module stuff
	VariableHandler = DialogueVariableHandler.new()
	add_child(VariableHandler)
	
	Inputs = DialogueInputHandler.new()
	Inputs.name = "Input"
	add_child(Inputs)
	
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


func start_from_path(path : String):
	if path.begins_with("res://"):
		if path.to_lower().ends_with(".dngraph") || path.to_lower().ends_with(".json"):
			print_debug("path - %s" % path)
			dialogue_tree = DialogueTree.new()
			dialogue_tree.open_from_path(path)
			
			variables = dialogue_tree.variables
		elif path.to_lower().ends_with(".tres") || path.to_lower().ends_with(".res"):
			dialogue_tree = load(path)
	
	started = true
	dialogue_started.emit()
	# else: search through a directory of dialogue trees?


func preload_tree(path : String, dialogue_box : DialogueBox):
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
	started = false


func stop():
	started = false
	dialogue_finished.emit()


func kill():
	started = false
	dialogue_box.kill()
	dialogue_finished.emit()


func play():
	var root = dialogue_tree.root_node
	load_next_dialogue(root.name, 0)


func play_branch(slot : int):
	var root = dialogue_tree.root_node
	load_next_dialogue(root.name, slot)


func play_at(name : String):
	load_dialogue(dialogue_tree.nodes[name])


func load_next_dialogue(name : String, slot):
	slot = float(slot)
	print("next - %s, %s" % [name, slot])
	print("conn - %s, %s, %s" % [dialogue_tree.connections, dialogue_tree.connections.has(name), dialogue_tree.connections[name].has(slot)])
	
	if(dialogue_tree.connections.has(name) && dialogue_tree.connections[name].has(slot)):
		var next = dialogue_tree.connections[name][slot]
		print("connections[root.name] %s" % [next])
		load_dialogue(dialogue_tree.nodes[next.to])
	else:
		print_debug("No connections left")
		dialogue_finished.emit()


func load_dialogue(dialogue : Dictionary):
	if(started): 
		push_warning("Dialogue already started...")
		return
	started = true
	print("dialogue - %s" % [dialogue])
	var type : Type = Type[dialogue.type] # type name -> enum
	var speaker : String = dialogue.speaker
	var text : String = dialogue.text
#	print_debug("loading dialogue - %s" % [variables])
	
	match(type):
		Type.Dialogue:
			pass
		Type.Offering:
			pass
		Type.Response:
			pass
	print_debug("VariableHandler %s" % [VariableHandler])
	var parsed := VariableHandler.parse_text(text)
	
#	DialogueInputHandler.accept_input.connect()
	await dialogue_box.load_dialogue(parsed, dialogue)
	
	dialogue_finished.emit()
	started = false


func _on_dialogue_finished(dialogue : Dictionary):
	print_debug("dialogue finished, try to move on to next.")
	var type : Type = Type[dialogue.type] # type name -> enum
	var speaker : String = dialogue.speaker
	var text : String = dialogue.text
#	print_debug("loading dialogue - %s" % [variables])
	
	match(type):
		Type.Dialogue:
			print_debug("current is dialogue, go to slot 0")
			load_next_dialogue(dialogue.name, 0)
		Type.Offering:
			print_debug("current is offering, bring up offering")
			load_next_dialogue(dialogue.name, 0)
#			await offering_submitted
		Type.Response:
			print_debug("current is response, go to slot of the chosen response")
			load_next_dialogue(dialogue.name, 0)
#			await response_chosen
