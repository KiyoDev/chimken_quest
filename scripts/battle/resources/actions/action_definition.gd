class_name ActionDefinition extends Resource


enum Category {
	Attack,
	Skill
}


@export var name := "";

@export_enum("Attack", "Skill") var category := "";


func act(actor : Character, targets):
	pass
