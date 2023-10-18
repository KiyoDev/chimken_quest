class_name Character extends CharacterBody2D


@onready var n_sprite := $Sprite2D;
@onready var n_animator := $AnimationPlayer;
@onready var n_job = $Job

@export var info : CharacterDefinition;


func _init():
	if(info == null):
		info = CharacterDefinition.new();
	
#	if(n_sprite == null):
#		n_sprite = Sprite2D.new();


func _ready():
	if(info == null):
		info = CharacterDefinition.new();
	if(n_sprite == null):
		n_sprite = Sprite2D.new();


# combat options: attack, skills, items, run
# how to store attack and skills?
#	inside a list or dict?
#		if in list, ui should grab the names and get the proper info from the ActionDatabase


func _clone(flags := 0b0111) -> Character:
	var char := super.duplicate(flags);
	char.info = info.duplicate();
	return char;


func _to_string():
	return "%s" % [info];
