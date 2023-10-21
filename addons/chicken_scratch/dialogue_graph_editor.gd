@tool
class_name DialogueGraphEditor extends VBoxContainer

@onready var Graph = $Graph;
var dialogue_node = preload("res://addons/chicken_scratch/dialogue_node.tscn");


func _on_add_node_pressed():
	print_debug("on add - %s, %s" % [Graph, dialogue_node]);
	Graph.add_child(dialogue_node.instantiate());


func _on_graph_connection_request(from_node, from_port, to_node, to_port):
	print("connection request - [%s, %s, %s ,%s]" % [from_node, from_port, to_node, to_port]);
	Graph.connect_node(from_node, from_port, to_node, to_port);


func _on_graph_disconnection_request(from_node, from_port, to_node, to_port):
	Graph.disconnect_node(from_node, from_port, to_node, to_port);
