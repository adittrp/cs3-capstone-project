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

func _ready():
	await get_tree().create_timer(1).timeout
	startRound(roundNumber)
	
func startRound(round):
	if round < 1:
		print("Invalid round number")
		return
	
	var roundData = roundSystem["Round" + str(round)]
	
	for enemy in roundData:
		for i in range(600/enemy[2]):
			await get_tree().create_timer(enemy[2]/20).timeout
			print()
			#for e in range(enemy[1]):
				#var angle = (TAU / number_of_objects) * i  # TAU = 2 * PI
				#var x = cos(angle) * radius
				#var y = sin(angle) * radius
				#var new_instance = object_scene.instantiate()
				#new_instance.position = Vector2(x, y) + position  # Offset from the current node's position
				#add_child(new_instance)
			#
			#var newEnemy = enemy.instantiate()
			#
			#var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
			#var spawn_position = global_position + offset
			#
			#newEnemy.position = coinManager.to_local(spawn_position)
			#coinManager.add_child(coin)
	
