extends Node2D

var roundSystem = {
	"Round1": [["Zombie", 50, 60]],
	"Round2": [],
	"Round3": [],
	"Round4": [],
	"Round5": []
}
var roundNumber : int = 1

@onready var enemy = load("res://scenes/enemy.tscn")
@onready var player = get_parent().get_node("Player") # Adjust path if needed

func _ready():
	await get_tree().create_timer(1).timeout
	startRound(roundNumber)
	
func startRound(round):
	await get_tree().create_timer(1).timeout
	
	
	if round < 1:
		print("Invalid round number")
		return
	
	var roundData = roundSystem["Round" + str(round)]
	
	for enemy_info in roundData:
		var count_per_wave = enemy_info[1]
		var interval_seconds = enemy_info[2]
		var number_of_waves = 10
		
		for wave in range(number_of_waves):
			spawn_enemies_around_player(count_per_wave)
			await get_tree().create_timer(interval_seconds).timeout

func spawn_enemies_around_player(count: int):
	for i in range(count):
		var new_enemy = enemy.instantiate()
		
		var angle = randf_range(0, TAU)
		var distance = 1750
		var offset = Vector2(cos(angle), sin(angle)) * distance
		new_enemy.position = player.global_position + offset
		
		add_child(new_enemy)
