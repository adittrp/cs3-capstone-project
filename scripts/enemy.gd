extends CharacterBody2D
class_name Enemy

var player: Player = null
var speed: float = 250.0
var direction := Vector2.ZERO
var health: int = 100

var cant_move: bool = false

func shot_at(shotPower):
	health -= shotPower
	if health <= 0:
		queue_free()

func _process(delta: float) -> void:
	if player != null:
		look_at(player.global_position)

func _physics_process(delta: float) -> void:
	if player != null and !cant_move:
		
		var enemy_to_player = (player.global_position - global_position)
		if enemy_to_player.length() > 20.0:
			direction = enemy_to_player.normalized()
		else:
			direction = Vector2.ZERO
		
		if direction != Vector2.ZERO:
			velocity = speed * direction
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)
			
		move_and_slide()

func stopped():
	cant_move = true
	await get_tree().create_timer(0.5).timeout
	cant_move = false
	

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		if player == null:
			player = body
