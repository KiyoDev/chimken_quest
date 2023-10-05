class_name Character extends Node2D


@onready var n_sprite := $Sprite2D;
@onready var n_animator := $AnimationPlayer;
@onready var n_job = $Job

@export var info : CharacterDefinition;


func _init():
	if(info == null):
		info = CharacterDefinition.new();

# combat options: attack, skills, items, run
# how to store attack and skills?
#	inside a list or dict?
#		if in list, ui should grab the names and get the proper info from the ActionDatabase


func _to_string():
	return "%s" % [info];
