extends Node2D

#var roundSystem = {
	#"Level1": [["Zombie", 75, 60]],
	#"Level2": [],
	#"Level3": [],
	#"Level4": [],
	#"Level5": [["Zombie", 75, 60]]
#}

# ok so this is dynamic or like automatic levels rather than like the huge dict previously we had
# I only have Zombie for now but like we can add other enemies 
func get_round_data(level: int) -> Array:
	var base_enemy_count = 50 + level * 5
	var interval_seconds = clamp(60 - level * 2, 10, 60)
	return [["Zombie", base_enemy_count, interval_seconds]]

var LevelNumber : int = 1

@onready var enemy = load("res://scenes/enemy.tscn")
@onready var player = get_parent().get_node("Player") # Adjust path if needed

func _ready():
	await get_tree().create_timer(1).timeout
	startRound(LevelNumber)
	
func startRound(level: int):
	await get_tree().create_timer(1).timeout

	var roundData = get_round_data(level)

	for enemy_info in roundData:
		var count_per_wave = enemy_info[1]
		var interval_seconds = enemy_info[2]
		var number_of_waves = 10

		for wave in range(number_of_waves):
			spawn_enemies_around_player(count_per_wave + wave * 5)

			SaveData.CoinValue = level + (0.1 * wave)
			SaveData.DamageScale = level + (0.1 * wave)

			await get_tree().create_timer(interval_seconds).timeout

	LevelNumber += 1
	startRound(LevelNumber)


func spawn_enemies_around_player(count: int):
	for i in range(count):
		var new_enemy = enemy.instantiate()
		
		var angle = randf_range(0, TAU)
		var distance = 2000
		var offset = Vector2(cos(angle), sin(angle)) * distance
		new_enemy.position = player.global_position + offset
		
		add_child(new_enemy)
