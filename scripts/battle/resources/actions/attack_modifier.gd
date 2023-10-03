class_name AttackModifier extends Resource


## Used to determine if the modifier can be applied
@export var conditions : Array[Condition] = []


func apply_mod(params : Dictionary) -> void:
	pass


func can_apply(params : Dictionary) -> bool:
	var apply := true
	for condition in conditions:
		apply = apply && condition.resolve(params)
	return apply
