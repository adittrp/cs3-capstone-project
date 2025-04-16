extends Control

#var bg_music = preload("res://main_menu_folder/audios/المقطع الاصلي للفار الموسيقار _ ساعة متواصلة مع الفأر الموسيقار 4.mp3")

#func _ready():
	## Duplicate the stream and enable looping
	#var music = bg_music.duplicate()
	#music.loop = true
	#
	## Set up and play the looping background music
	#$AudioStreamPlayer2D.stream = music
	#$AudioStreamPlayer2D.volume_db = -6  # Optional: reduce if too loud
	#$AudioStreamPlayer2D.play()

func _on_start_pressed() -> void:
	print("Start pressed...")
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_options_pressed() -> void:
	print("Settings pressed...")

func _on_exit_pressed() -> void:
	get_tree().quit()


	
