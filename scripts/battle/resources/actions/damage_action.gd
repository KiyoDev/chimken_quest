## Action to damage target(s)
class_name DamageAction extends ActionDefinition

@export_enum("physical", "magic") var type := "physical";

@export_enum("attack", "magic", "defense", "magic_resist") var scaling_stat := "attack";

## % of stat to use during damage calculation
@export var value := 0.80;

@export var attack_modifiers : Array[AttackModifier] = [];


func act(actor : Character, targets):
	pass;


func damage_value(character : Character) -> int:
	var stat_value = character.info.get(scaling_stat);
	var multiplier = maxf(0.01, value);
	return ceili(stat_value * multiplier);
