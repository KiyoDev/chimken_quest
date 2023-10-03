class_name DamageCalculator extends RefCounted


const player_defense_multiplier := 0.95
const enemy_defense_multiplier := 0.6
const level_multiplier := 1.225
const level_constant := 1.725

#
static func standard(
	attacker : Character,
	target : Character,
	damage_action : DamageAction
) -> int:
	# stats
	var level := attacker.info.level;
	var attack_value : int = damage_action.damage_value(attacker);
	
	var defense := target.info.defense if damage_action.type == "physical" else target.info.magic_resist;
	
	var defense_multiplier := player_defense_multiplier if target.info.type == "Ally" else enemy_defense_multiplier;
	
	# multipliers
	var pierce := 0.0 # TODO: implement
	var damage_reduction : float = 1; #- target_attributes.resilience.get_total_value() + target_damage_reduction
	var elemental_resistance_multiplier := elemental_resist(target, damage_action)
	var final_damage_multiplier : float = 1; #+ potency + attacker_damage_multipliers + elemental_mastery_multiplier
	
	# damage calc
	var base_damage := base_damage(level, attack_value, defense, defense_multiplier, pierce)
	var damage := roundi(base_damage * final_damage_multiplier * damage_reduction * elemental_resistance_multiplier)
	return damage;

# 
static func base_damage(
	level : int,
	attack_value : int,
	defense : int,
	defense_multiplier : float,
	pierce : float,
) -> float:
	var total_defense := maxi(1, (defense - (defense * pierce)) * defense_multiplier)
	var damage : int = maxi(1, (attack_value * (level * level_multiplier + level_constant) / total_defense));
	return damage;
	

static func elemental_resist(
	target : Character, 
	attack : DamageAction
) -> float:
	var elemental_resistances = target.attributes.elemental_resistances
	var value := 1.0
	for element in Elements.from_flags(attack.elements):
		value -= elemental_resistances[element]
	
	return value
