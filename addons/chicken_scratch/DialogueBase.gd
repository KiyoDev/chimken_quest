class_name DialogueBase extends Resource


# if using dialogue icons, then need dict<name, icon>
@export var speaker := "";


## Text to display in a dialogue box.
#@export var dialogue := "";
@export var lines : Array[DialogueLine] = [];


# no reference to next; will just be created while file is being read
