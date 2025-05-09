extends Control

# Called when the Start button is pressed
func _on_start_pressed() -> void:
	print("Start pressed...")
	get_tree().change_scene_to_file("res://scenes/world.tscn")

# Called when the Options/Settings button is pressed
func _on_options_pressed() -> void:
	print("Settings pressed...")
	get_tree().change_scene_to_file("res://upgrade_screen_folder/upgrade_screen.tscn")

# Called when the Exit button is pressed
func _on_exit_pressed() -> void:
	get_tree().quit()
