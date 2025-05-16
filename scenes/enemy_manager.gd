# World/scripts/RoundManager.gd
extends Node2D
class_name RoundManager

var RoundDone: bool = false
var LevelNumber: int = SaveData.RoundLevel

@onready var zombie_scene: PackedScene    = preload("res://scenes/enemy.tscn")
@onready var bat_scene:    PackedScene    = preload("res://scenes/spooky_bat.tscn")

@onready var player: Node2D               = get_parent().get_node("Player")
@onready var game_over_panel: Panel       = get_node("../UI/Panel")
@onready var msg_label: Label             = game_over_panel.get_node("Label")
@onready var retry_button: Button         = game_over_panel.get_node("RetryButton")
@onready var exit_button: Button          = game_over_panel.get_node("ExitButton")

func _ready() -> void:
	game_over_panel.visible = false
	if not zombie_scene or not bat_scene:
		push_error("RoundManager: failed to preload enemy scenes.")
		return

	player.died.connect(_on_player_died)
	retry_button.pressed.connect(_on_retry_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	await get_tree().create_timer(1.0).timeout
	await start_round(LevelNumber)
	SaveData.RoundLevel = LevelNumber

func _process(delta: float) -> void:
	if RoundDone and get_child_count() == 0:
		_on_round_passed()

func get_round_data(level: int) -> Array:
	var z_base = 5  + (level - 1) * 20
	var b_base = 3  + (level - 1) * 5
	return [
		{"type":"Zombie", "base":z_base, "interval":30.0},
		{"type":"Bat",    "base":b_base, "interval":20.0}
	]

func start_round(level: int) -> void:
	print("[RoundManager] start_round(level=%d)" % level)
	RoundDone = false
	await get_tree().create_timer(1.0).timeout

	var rd    = get_round_data(level)
	var z_inf = rd[0]
	var b_inf = rd[1]
	var waves = 1

	for w in range(waves):
		var z_count = z_inf.base + w
		var b_count = b_inf.base + w
		print("[RoundManager] Wave %d/%d — Zombies=%d, Bats=%d"
			  % [w+1, waves, z_count, b_count])

		spawn_around_player("Zombie", z_count)
		spawn_around_player("Bat",    b_count)

		SaveData.CoinValue   = level + 0.05 * w
		SaveData.DamageScale = level + 0.05 * w

		var delay = min(z_inf.interval, b_inf.interval)
		await get_tree().create_timer(delay).timeout

	RoundDone = true
	print("[RoundManager] Round %d complete" % level)

func spawn_around_player(enemy_type: String, count: int) -> void:
	if not is_instance_valid(player):
		push_error("RoundManager: Player invalid")
		return

	var scene: PackedScene = null
	if enemy_type == "Zombie":
		scene = zombie_scene
	elif enemy_type == "Bat":
		scene = bat_scene
	else:
		push_error("RoundManager: no scene for '%s'" % enemy_type)
		return

	var center = player.global_position
	for i in range(count):
		var inst    = scene.instantiate() as Node2D
		var angle   = randf_range(0, TAU)
		var offset  = Vector2.ZERO
		if enemy_type == "Zombie":
			offset = Vector2(cos(angle), sin(angle)) * 1500
		else:
			offset = Vector2(cos(angle), sin(angle)) * randf_range(1000,1500) + Vector2(0, -200)
		inst.global_position = center + offset
		add_child(inst)

func _on_player_died() -> void:
	print("[RoundManager] Player died")
	msg_label.text = "You Died!"
	game_over_panel.visible = true
	set_process(false)

func _on_round_passed() -> void:
	LevelNumber += 1
	print("[RoundManager] Advancing to level %d" % LevelNumber)
	SaveData.RoundLevel = LevelNumber
	if LevelNumber > SaveData.MaxUnlockedLevel:
		SaveData.MaxUnlockedLevel = LevelNumber
	SaveData.save_game()
	msg_label.text = "Level Passed!"
	game_over_panel.visible = true
	set_process(false)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels_menu.tscn")
