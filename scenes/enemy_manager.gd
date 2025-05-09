extends Node2D

func get_round_data(level: int) -> Array:
	# Define enemy count and interval dynamically based on the level
	var base_enemy_count = 10 + (level - 1) * 15
	var interval_seconds = 30
	
	# [EnemyType, Count, Interval]
	return [["Zombie", base_enemy_count, interval_seconds]]

var LevelNumber : int = 1

@onready var enemy = load("res://scenes/enemy.tscn")
@onready var player = get_parent().get_node("Player")

func _ready():
	# Slight delay before starting the first round
	await get_tree().create_timer(1).timeout
	startRound(LevelNumber)
	SaveData.RoundLevel = LevelNumber

func startRound(level: int):
	await get_tree().create_timer(1).timeout

	var roundData = get_round_data(level)

	for enemy_info in roundData:
		var count_per_wave = enemy_info[1]
		var interval_seconds = enemy_info[2]
		var number_of_waves = 20

		for wave in range(number_of_waves - 1):
			# Spawn more enemies each wave to increase difficulty
			spawn_enemies_around_player(count_per_wave + wave * 3)

			# Dynamically adjust difficulty scaling
			SaveData.CoinValue = level + (0.05 * wave)
			SaveData.DamageScale = level + (0.05 * wave)

			await get_tree().create_timer(interval_seconds).timeout

	# After completing the round, move to the next one
	LevelNumber += 1
	SaveData.RoundLevel = LevelNumber
	startRound(LevelNumber)

func spawn_enemies_around_player(count: int):
	for i in range(count):
		var new_enemy = enemy.instantiate()
		
		# Position each enemy in a circle around the player
		var angle = randf_range(0, TAU)
		var distance = 1250
		var offset = Vector2(cos(angle), sin(angle)) * distance
		new_enemy.position = player.global_position + offset
		
		add_child(new_enemy)
