extends Area2D

@export var value: int = 1
@onready var sfx := $AudioStreamPlayer2D
@onready var sprite := $Sprite2D
@onready var collider := $CollisionShape2D

var attracted : bool = false
var target_player = null
var attract_time : float = 0.0

func _process(delta):
	collider.scale = Vector2.ONE * (1.25 + (0.5 * float(SaveData.magnetUpgradeLevel)))

	# If attracted to the player, move toward them
	if attracted and target_player:
		attract_time += delta
		
		var speed = 350.0 * pow(4.25, attract_time)
		var direction = (target_player.global_position - global_position).normalized()
		global_position += direction * speed * delta

		# Optional: stop moving when very close
		if global_position.distance_to(target_player.global_position) < 10.0:
			collect()

func _on_body_entered(body):
	if body.name == "Player":
		attracted = true
		target_player = body
		set_deferred("monitoring", false)

func collect():
	get_node("/root/World").add_coin(value)
	sfx.play()
	sprite.visible = false
	collider.disabled = true

	await sfx.finished
	queue_free()
