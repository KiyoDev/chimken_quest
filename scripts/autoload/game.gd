extends Node


enum State {
	LOADING,
	MAIN_MENU,
	OVERWORLD,
	BATTLE,
	PAUSED,
	CUTSCENE
}


enum Direction {
	NONE	= 0b0000,
	UP		= 0b0001,
	DOWN	= 0b0010,
	LEFT	= 0b0100,
	RIGHT	= 0b1000
}


var state := State.LOADING;


func _ready():
	# Snap transforms to pixel;
	RenderingServer.viewport_set_snap_2d_transforms_to_pixel(get_viewport(), true);


func in_battle():
	return state == State.BATTLE;


func battle():
	state = State.BATTLE;


func overworld():
	state = State.OVERWORLD;
