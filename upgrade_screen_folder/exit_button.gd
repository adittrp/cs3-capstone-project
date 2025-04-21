extends Button

# Path to your main menu scene
@export var main_menu_scene_path: String = "res://main_menu_folder/main_menu.tscn"

func _ready() -> void:
	# Connect this button’s pressed signal to our handler
	connect("pressed", Callable(self, "_on_back_to_main_pressed"))

func _on_back_to_main_pressed() -> void:
	# Verify the scene file exists before changing
	if ResourceLoader.exists(main_menu_scene_path):
		get_tree().change_scene_to_file(main_menu_scene_path)
	else:
		push_error("Cannot find Main Menu scene at: %s" % main_menu_scene_path)
