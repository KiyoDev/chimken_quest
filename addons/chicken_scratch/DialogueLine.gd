class_name DialogueLine extends Resource


enum Modifier {
	None,
	Slow,
	Fast,
	Wave
}


@export var modifier := Modifier.None;
@export var value := {"value": null};
@export var line := "";
