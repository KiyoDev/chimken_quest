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

# TODO: camera bound system. be able to designate the level boundaries and clamp camera to those bounds
func _ready():
	# Snap transforms to pixel;
	RenderingServer.viewport_set_snap_2d_transforms_to_pixel(get_viewport(), true);
	
	var current_scene := get_tree().current_scene;
	var player := get_tree().get_first_node_in_group("Player");
	# TODO: quick test for reparenting player to tilemap
	if(player == null): return;
	
	print("player - %s, %s, %s, %s, %s" % [player, current_scene, current_scene.get_node("Area"), get_tree().get_first_node_in_group("Bounds"), player.Camera]);
	
	
	player.reparent(current_scene.get_node("Area").get_node("TileMap"));
	await get_tree().create_timer(0.001).timeout # FIXME: figure out how to fix workaround
	player.Camera.set_scroll_limits(get_tree().get_first_node_in_group("Bounds"));


func in_battle():
	return state == State.BATTLE;


func battle():
	state = State.BATTLE;


func overworld():
	state = State.OVERWORLD;
