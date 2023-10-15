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



func in_battle():
	return state == State.BATTLE;


func battle():
	state = State.BATTLE;


func overworld():
	state = State.OVERWORLD;
