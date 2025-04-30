extends Node2D

@export var coin_scene: PackedScene
@export var coin_count: int = 100
@export var player: Node2D
@export var spawn_radius: float = 10000

func _ready():
	randomize()
	for i in coin_count:
		var coin = coin_scene.instantiate()
		var angle = randf() * TAU
		var radius = randf() * spawn_radius
		var offset = Vector2(cos(angle), sin(angle)) * radius
		coin.position = player.global_position + offset
		add_child(coin)
