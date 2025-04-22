extends Node2D

@onready var player = $Player
@onready var main_camera = $MainCamera

func _ready() -> void:
	player.died.connect(_on_player_died)
	player.camera_remote_transform.remote_path = main_camera.get_path()
	
	# -- initialize health bar -- #
	var health_bar = get_node("/root/World/UI/HealthBar")
	var health_label = get_node("/root/World/UI/HealthLabel")
	health_bar.value = player.curHealth
	health_label.text = str(player.curHealth) + " HP"
	# -- end of initialize health bar -- #

func _on_player_died():
	print("game over")
	get_tree().create_timer(3).timeout.connect(get_tree().reload_current_scene)
