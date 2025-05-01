extends Area2D

@export var value: int = 1
@onready var sfx: AudioStreamPlayer2D    = $AudioStreamPlayer2D
@onready var sprite: Sprite2D            = $Sprite2D
@onready var collider: CollisionShape2D  = $CollisionShape2D

var attracted: bool = false
var target_player: Node = null
var attract_time: float = 0.0
var collected: bool = false

func _ready() -> void:
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	if collected:
		return

	# expand/shrink with magnet upgrade
	collider.scale = Vector2.ONE * (1.25 + 0.65 * float(SaveData.magnetUpgradeLevel))

	if attracted and target_player:
		attract_time += delta
		var speed := 350.0 * pow(4.25, attract_time)
		var dir: Vector2 = (target_player.global_position - global_position).normalized()
		global_position += dir * speed * delta

		if global_position.distance_to(target_player.global_position) < 10.0:
			collect()

func _on_body_entered(body: Node) -> void:
	if collected:
		return
	if body.name == "Player":
		attracted = true
		target_player = body
		monitoring = false    # stop detecting further overlaps

func collect() -> void:
	collected = true

	# add exactly one coin
	get_node("/root/World").add_coin(value)

	# play pickup sound once
	sfx.play()

	# hide and disable
	sprite.visible = false
	collider.disabled = true

	# stop _process
	set_process(false)

	# free after sound ends
	await sfx.finished
	queue_free()
	
	
