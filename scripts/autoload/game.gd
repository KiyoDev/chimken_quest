extends Node


enum State {
	LOADING,
	MAIN_MENU,
	OVERWORLD,
	BATTLE,
	PAUSED,
	CUTSCENE
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
