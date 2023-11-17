class_name GraphPlayScene extends Control


@export var dialogue_box_scn : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	var box : DialogueBox = dialogue_box_scn.instantiate()
	box.set_theme(load("res://addons/chicken_scratch/theme/white_font_small_outline.theme"))
	add_child(box)
	
	var tree_path = EditorUtil.get_editor_setting("current_tree")
	if(!tree_path):
		print_debug("Current tree path not found - %s" % [tree_path])
		get_tree().quit()
		return
		
	ChickenScratch.preload_tree(tree_path, box)
	print_debug("play current tree[%s] in scene - %s" % [ChickenScratch.dialogue_tree.path, ChickenScratch.dialogue_tree._to_string()])
	
	
	ChickenScratch.dialogue_finished.connect(get_tree().quit)
	ChickenScratch.play_branch(1)


# TODO: figure out how to play scene
