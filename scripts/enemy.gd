extends CharacterBody2D
class_name Enemy

@onready var coin_scene = load("res://scenes/coin.tscn")
@onready var coinManager = get_parent().get_parent().get_node("CoinManager")
@onready var player = get_parent().get_parent().get_node("Player")

#var player: Player = null
var speed: float = randf_range(100, 175)
var direction := Vector2.ZERO
var max_health = 100
var health: int = 100
var cant_move: bool = false
var wander_timer := 0.0
@onready var health_bar = $HealthBar/ProgressBar

# Cardinal directions (no diagonals)
var directions := [
	Vector2.LEFT,
	Vector2.RIGHT,
	Vector2.UP,
	Vector2.DOWN
]

func _ready() -> void:
	update_health_bar()
	
func shot_at(shotPower):
	health -= shotPower

	if health <= 0:
		for i in range(SaveData.RoundLevel):
			var coin = coin_scene.instantiate()
			
			var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
			var spawn_position = global_position + offset
			
			coin.position = coinManager.to_local(spawn_position)
			coinManager.add_child(coin)
		
		queue_free()
	else:
		update_health_bar()
		
func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		look_at(global_position + direction * 50)

func _physics_process(delta: float) -> void:
	if cant_move:
		return
	if player:
		if (player.invincible):
			return
		var to_player = player.global_position - global_position
		if to_player.length() > 20.0:
			direction = to_player.normalized()
			velocity = direction * speed
		else:
			direction = Vector2.ZERO
			velocity = Vector2.ZERO

		move_and_slide()

func stopped():  
	cant_move = true
	await get_tree().create_timer(0.3).timeout
	cant_move = false

func update_health_bar():
	health_bar.value = health
	health_bar.max_value = max_health

	
