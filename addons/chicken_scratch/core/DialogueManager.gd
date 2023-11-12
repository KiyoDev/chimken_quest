@tool
extends Node


signal offering_submitted

signal response_chosen

signal dialogue_paused

signal dialogue_resumed

signal dialogue_finished


enum Type {
    Dialogue,
    Offering,
    Response
}


@export var dialogue_box : DialogueBox

var VariableHandler : DialogueVariableHandler

var variables := {} # { "name": <value> }

var dialogue_tree := {}
var connections := {}


func _ready():
    # module stuff
    VariableHandler = DialogueVariableHandler.new()
    add_child(VariableHandler)
    print("VariableHandler %s" % [VariableHandler])


func connection_dict() -> Dictionary:
    var connections := {}
    for connection in dialogue_tree.connections:
        if(!connections.has(connection.from)):
#			print_debug("add new connection to dict")
            connections[connection.from] = {}
        # support multiple connections at same "from_port"?
        connections[connection.from][connection.from_port] = {"to": connection.to, "to_port": connection.to_port}
    
    return connections


func load_dialogue_tree(dialogue_tree : Dictionary):
    if(!dialogue_box.dialogue_finished.is_connected(_on_dialogue_finished)):
        dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
        dialogue_box.restart()
    self.dialogue_tree = dialogue_tree
    connections = connection_dict()
    print_debug("loading tree - %s" % [variables])
#	print_debug("connections - %s" % [connections])


func play_branch(slot : int):
    var root = dialogue_tree.root_node
    load_next_dialogue(root.name, slot)


func play():
    var root = dialogue_tree.root_node
    # TODO
    load_next_dialogue(root.name, 1)


func load_next_dialogue(name : String, slot : int):
    print("next - %s, %s" % [name, slot])
    if(connections.has(name) && connections[name].has(slot)):
        var next = connections[name][slot]
        print("connections[root.name] %s" % [next])
        load_dialogue(dialogue_tree.nodes[next.to])
    else:
        print_debug("No connections left")
        dialogue_finished.emit()


func load_dialogue(dialogue : Dictionary):
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

    dialogue_box.load_dialogue(parsed, dialogue)


func put_variables(text : String) -> String:
    for variable_name in variables:
        text = text.replace("${%s}" % variable_name, str(variables[variable_name]))
    
    return text


func _input(event):
    pass


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
