class_name EditorUtil extends Node

const SETTINGS_PATH := "user://chicken_scratch/editor_settings.cfg"


static func set_editor_setting(setting : String, value : Variant) -> void:
	var cfg := ConfigFile.new()
	if FileAccess.file_exists(SETTINGS_PATH):
#		print_debug("File '%s' found" % [SETTINGS_PATH])
		cfg.load(SETTINGS_PATH)

	cfg.set_value("editor_settings", setting, value)

	if !DirAccess.dir_exists_absolute("user://chicken_scratch"):
		DirAccess.make_dir_absolute("user://chicken_scratch")
#		print_debug("Directory 'user://chicken_scratch' not found; making directory...")
	var err := cfg.save(SETTINGS_PATH)
	
#	print_debug("on set setting - %s" % [err])


static func get_editor_setting(setting : String, default : Variant = null) -> Variant:
	var cfg := ConfigFile.new()
	if !FileAccess.file_exists(SETTINGS_PATH):
		push_error("File '%s' doesn't exist" % [SETTINGS_PATH])
		return default
	
	var err := cfg.load(SETTINGS_PATH)
#	print_debug("on get setting - %s" % [err])
	if(err != OK):
		push_error("Unable to load config file")
		return default
		
	return cfg.get_value('editor_settings', setting, default)
