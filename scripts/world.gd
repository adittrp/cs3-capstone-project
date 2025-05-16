extends Node2D

# Reference other nodes
@onready var player = $Player
@onready var main_camera = $MainCamera
@onready var coin_display: Label = $UI/CoinsPanel/CoinsLabel/CoinDisplay
@onready var popup_menu_panel = $HUD/PopupMenuPanel
@onready var hud = get_node("HUD")
@onready var ui = get_node("UI")
@onready var timer_label: Label = $UI/TimePanel/Control/Label

@onready var Map1 = $Tilemapstuffs/Map1
@onready var Map2 = $Tilemapstuffs/Map2
@onready var Map3 = $Tilemapstuffs/Map3

var maps := [Map1, Map2, Map3]

var time_elapsed := 0.0

# Called when the node is ready
func _ready() -> void:
	# Hide the popup menu initially
	popup_menu_panel.visible = false
	#print("level: " + str(SaveData.RoundLevel))
	# Unpause the game tree
	get_tree().paused = false
	
	# Start background audio loop
	$BackgroundAudio.stream.loop = true
	$BackgroundAudio.play()
	
	# Connect player death signal
	#player.died.connect(_on_player_died)
	player.camera_remote_transform.remote_path = main_camera.get_path()

	# Initialize health bar and label
	var health_bar = get_node("/root/World/UI/HealthBar")
	var health_label = get_node("/root/World/UI/HealthLabel")
	health_bar.value = player.curHealth
	health_label.text = str(player.curHealth) + " HP"
	
	# Update coin display after a short delay
	await get_tree().create_timer(0.1).timeout
	_update_coin_display()
	
	# Update Map
	var Round = SaveData.get_level()
	Map1.enabled = (Round == 1)
	Map2.enabled = (Round == 2)
	Map3.enabled = (Round != 1 and Round != 2)
	
# Called every frame
func _process(delta: float) -> void:
	# Update elapsed time and display it
	if player and !player.invincible:
		time_elapsed += delta
	var minutes = time_elapsed / 60
	var seconds = int(time_elapsed) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

# Called when the player dies
#func _on_player_died():
	#get_tree().create_timer(3).timeout.connect(get_tree().reload_current_scene)

# Adds coins based on value passed
func add_coin(value) -> void:
	# Update coins with modifiers and save the game
	SaveData.coins += 1 + int((SaveData.CoinValue * value) * (1.5 * (SaveData.coinMultiplierUpgradeLevel)))
	SaveData.save_game()
	
	_update_coin_display()

# Updates the coin display UI
func _update_coin_display() -> void:
	coin_display.text = str(SaveData.coins) + " COINS"

# Toggles the visibility of the popup menu and player invincibility
func _on_menu_button_pressed() -> void:
	
	# Toggle visibility of the popup menu
	popup_menu_panel.visible = !popup_menu_panel.visible
	if player:
		player.invincible = !(player.invincible)
	# Update the coin display
	_update_coin_display()

# Called when the "Leave Level" button is pressed
func _on_leave_level_button_pressed() -> void:
	# Change to the main menu scene
	print("Leave Level button pressed")
	get_tree().change_scene_to_file("res://main_menu_folder/main_menu.tscn")

# Called when the "Upgrades" button is pressed
func _on_upgrades_button_pressed() -> void:
	# Load the upgrade scene
	print("Upgrades button pressed")
	var upgrade_scene = preload("res://upgrade_screen_folder/upgrade_screen.tscn")
	
	var upgrade_instance = upgrade_scene.instantiate()
	# Set return target for upgrades
	upgrade_instance.return_target = "in_game"
	
	# Ensure upgrade UI appears above other elements
	upgrade_instance.z_index = 100
	
	# Add the upgrade instance to the scene
	add_child(upgrade_instance)
	
	# Connect the signal for closing the upgrade popup
	upgrade_instance.show_popup_requested.connect(_on_upgrade_closed)
	
	# Hide HUD and UI during upgrades
	$HUD.visible = false
	$UI.visible = false

# Called when the "Settings" button is pressed
func _on_settings_button_pressed() -> void:
	print("Settings button pressed")

# Called when the upgrade popup is closed
func _on_upgrade_closed() -> void:
	$HUD.visible = true
	$UI.visible = true
