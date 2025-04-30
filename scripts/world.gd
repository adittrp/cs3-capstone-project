extends Node2D

@onready var player = $Player
@onready var main_camera = $MainCamera
@onready var coin_display: Label = $UI/CoinsPanel/CoinsLabel/CoinDisplay

func _ready() -> void:
	
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
	
	

func _on_player_died():
	print("game over")
	get_tree().create_timer(3).timeout.connect(get_tree().reload_current_scene)

func add_coin(amount: int = 1) -> void:
	SaveData.coins += int(amount * (1.5 * float(SaveData.coinMultiplierUpgradeLevel)))
	SaveData.save_game()   # ← persist immediately
	_update_coin_display()

func _update_coin_display() -> void:
	coin_display.text = str(SaveData.coins) + " COINS"
