class_name CharacterDefinition extends Resource


signal damaged;

signal gained_exp;

signal leveled_up;


@export var character_name := "placeholder";
@export_enum("Ally", "Enemy") var type := "Ally"; 

@export_group("Level")
@export var level := 1;

@export var curr_exp := 0;

@export var exp_needed := 0;

@export_group("Stats")
@export var max_hp := 10;

@export var max_mp := 10;

@export var curr_hp := 10;

@export var curr_mp := 10;

@export var attack := 5;

@export var magic := 5;

@export var defense := 5;

@export var magic_resist := 5;

@export var speed := 5;

@export var luck := 5;

@export_group("Multipliers")
## Bonus chance for attacks to be critical hits.
@export var crit_rate := 0.0;
## Affects the damage that critical hits do.
@export var crit_damage := 0.0;
## Pierce through the targets' defense. Ignores a % of defense during damage calculation.
@export var pierce := 0.0;

@export var fire_mastery := 0.0;
@export var water_mastery := 0.0;
@export var electric_mastery := 0.0;
@export var earth_mastery := 0.0;
@export var wind_mastery := 0.0;
@export var light_mastery := 0.0;
@export var dark_mastery := 0.0;
@export var void_mastery := 0.0;

@export var fire_resist := 0.0;
@export var water_resist := 0.0;
@export var electric_resist := 0.0;
@export var earth_resist := 0.0;
@export var wind_resist := 0.0;
@export var light_resist := 0.0;
@export var dark_resist := 0.0;
@export var void_resist := 0.0;


func _init():
	if(level == 99):
		return;
	exp_needed = ExperienceTable.exp_to_next_level(level + 1) - curr_exp;


func add_exp(exp : int):
	if(level == 99 || exp <= 0):
		return;
	
	gained_exp.emit(self, curr_exp, exp); # emit original exp and gained exp
	
	var new_total : int = min(ExperienceTable.max_exp, curr_exp + exp);
	var next_lvl := level;
	# exp=100, need=50, lv=10
	# -> leftover=50, need 90, lv=11
	# exp=1000, need=50
	# leftover=950, need=100, lo->850
	#	850, 200, ->650
	#		650, 400, ->250
	#			250, 800, ->0
	var leftover = max(0, new_total - exp_needed);
	while(leftover > 0):
#		exp_needed = max(0, exp_needed - new_total);
		next_lvl += 1;
		
		if(next_lvl > 99):
			new_total = 0;
			exp_needed = 0;
			break;
			
		new_total = leftover;
		exp_needed = ExperienceTable.exp_to_next_level(next_lvl);
		leftover = max(0, leftover - exp_needed);
	
	if(next_lvl > level):
		curr_exp = new_total;
		exp_needed -= curr_exp;
		leveled_up.emit(self, level, next_lvl); # emit original level and new level for front end
		level = next_lvl;
