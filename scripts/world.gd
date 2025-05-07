extends Node2D

@onready var player = $Player
@onready var main_camera = $MainCamera
@onready var coin_display: Label = $UI/CoinsPanel/CoinsLabel/CoinDisplay
@onready var popup_menu_panel = $HUD/PopupMenuPanel
@onready var hud = get_node("World/HUD")
@onready var ui = get_node("World/UI")
@onready var timer_label: Label = $UI/TimePanel/Control/Label
var time_elapsed := 0.0  # in seconds


func _ready() -> void:
	
	popup_menu_panel.visible = false
	get_tree().paused = false
	
	$BackgroundAudio.stream.loop = true 
	$BackgroundAudio.play()
	player.died.connect(_on_player_died)
	player.camera_remote_transform.remote_path = main_camera.get_path()

	# -- initialize health bar -- #
	var health_bar = get_node("/root/World/UI/HealthBar")
	var health_label = get_node("/root/World/UI/HealthLabel")
	health_bar.value = player.curHealth
	health_label.text = str(player.curHealth) + " HP"
	# -- end of initialize health bar -- #
	
	# set initial coin display
	await get_tree().create_timer(0.2).timeout
	_update_coin_display()
	

func _process(delta: float) -> void:
	if player and !player.invincible:
		time_elapsed += delta

	var minutes = int(time_elapsed) / 60
	var seconds = int(time_elapsed) % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]
		

func _on_player_died():
	print("game over")
	get_tree().create_timer(3).timeout.connect(get_tree().reload_current_scene)

func add_coin(value) -> void:
	SaveData.coins += 1 + int((SaveData.CoinValue * value) * (1.5 * (SaveData.coinMultiplierUpgradeLevel)))
	SaveData.save_game()   # ← persist immediately
	
	_update_coin_display()
	

func _update_coin_display() -> void:
	coin_display.text = str(SaveData.coins) + " COINS"


func _on_menu_button_pressed() -> void:
	
		
	popup_menu_panel.visible = !popup_menu_panel.visible
	if player:
		player.invincible = !(player.invincible)
	#get_tree().paused = not get_tree().paused


func _on_leave_level_button_pressed() -> void:
	print("Leave Level button pressed")
	#queue_free()
	get_tree().change_scene_to_file("res://main_menu_folder/main_menu.tscn")
	
	


func _on_upgrades_button_pressed() -> void:
	print("Upgrades button pressed")
	var upgrade_scene = preload("res://upgrade_screen_folder/upgrade_screen.tscn")
	var upgrade_instance = upgrade_scene.instantiate()

	upgrade_instance.return_target = "in_game"
	upgrade_instance.z_index = 100
	add_child(upgrade_instance)

	# Connect the signal to a local function
	upgrade_instance.show_popup_requested.connect(_on_upgrade_closed)

	# Hide HUD and UI while upgrade is open
	$HUD.visible = false
	$UI.visible = false


func _on_settings_button_pressed() -> void:
	print("Settings button pressed")


func _on_upgrade_closed() -> void:
	$HUD.visible = true
	$UI.visible = true
