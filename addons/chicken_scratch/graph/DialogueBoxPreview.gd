@tool
class_name DialogueBoxPreview extends Window



@export var dialogue_box : DialogueBox;

static var ChangeThemeDialog : EditorFileDialog;


# Called when the node enters the scene tree for the first time.
func _ready():
	ChangeThemeDialog = EditorFileDialog.new();
	ChangeThemeDialog.size = Vector2i(800, 400);
	ChangeThemeDialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE;
	ChangeThemeDialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS;
#	SaveFileDialog.transient = true;
	ChangeThemeDialog.add_filter("*.theme", "UI Theme");
	ChangeThemeDialog.file_selected.connect(_on_change_theme);
	add_child(ChangeThemeDialog);


func load_dialogue(text : String):
	dialogue_box.load_dialogue(text);
	

func _on_change_theme_pressed():
	ChangeThemeDialog.show();


func _on_remove_theme_pressed():
	dialogue_box.theme = null;
#	dialogue_preview.get_node("Container/VBoxContainer/ThemeLabel").text = "[default_theme]";
  

func _on_change_theme(path : String):
	var theme : Theme = load(path);
	dialogue_box.set_theme(theme);
#	dialogue_preview.get_node("Container/VBoxContainer/ThemeLabel").text = path.get_file();

