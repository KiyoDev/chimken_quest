class_name ActionDefinition extends Resource


enum Category {
	Attack	= 1,
	Skill	= 2
}

enum Target {
	Ally	= 0b0001,
	Enemy	= 0b0010,
	All		= 0b0011,
	Self	= 0b0100
}

enum TargetingType {
	Single	= 1,
	AoE		= 2
}

@export var name := "";

@export_multiline var description := "";

@export_enum("Attack:1", "Skill:2") var category := Category.Attack as int;

@export_flags("Ally:1", "Enemy:2", "Self:4") var target := 2;

@export_enum("Single:1", "AoE:2") var targeting_type := 1;


func act(actor : Character, targets):
	pass


static func _category(key : String) -> Category:
	return Category[key];


static func _target(key : String) -> Target:
	return Target[key];


static func _targeting_type(key : String) -> TargetingType:
	return TargetingType[key];


func _to_string():
	return "action={%s, %s, %s, %s}" % [name, Category.keys()[category - 1], target, TargetingType.keys()[targeting_type - 1]];
