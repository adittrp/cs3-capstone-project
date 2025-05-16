extends Area2D

# Coin value (how much it adds to total when picked up)
@export var value: int = 1

# References to internal nodes
@onready var sfx: AudioStreamPlayer2D    = $AudioStreamPlayer2D
@onready var sprite: Sprite2D            = $Sprite2D
@onready var collider: CollisionShape2D  = $CollisionShape2D

# State flags and variables
var attracted: bool = false
var target_player: Node = null
var attract_time: float = 0.0
var collected: bool = false

# Make sure only one coin sound plays
static var soundPlaying = false

func _ready() -> void:
	# Start monitoring for body overlaps and connect signal manually
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	if collected:
		return

	# Adjust pickup radius based on magnet upgrade
	collider.scale = Vector2.ONE * (1.25 + 0.65 * float(SaveData.magnetUpgradeLevel))

	# Move toward the player if attracted
	if attracted and target_player:
		attract_time += delta
		var speed := 350.0 * pow(4.25, attract_time)  # exponential speed increase
		var dir: Vector2 = (target_player.global_position - global_position).normalized()
		global_position += dir * speed * delta

		# If close enough, trigger collection
		if global_position.distance_to(target_player.global_position) < 10.0:
			collect()

func _on_body_entered(body: Node) -> void:
	if collected:
		return

	# If player touches the coin, start attracting it
	if body.name == "Player":
		attracted = true
		target_player = body
		monitoring = false  # stop detecting other overlaps once targeted

func collect() -> void:
	collected = true

	# Add to coin total in World singleton
	get_node("/root/World").add_coin(value)

	# Play pickup sound effect
	if !soundPlaying:
		sfx.play()
		soundPlaying = true

	# Hide the coin visually and disable collisions
	sprite.visible = false
	collider.disabled = true

	# Stop processing further
	set_process(false)

	# Wait until the sound finishes before freeing the node
	if soundPlaying:
		await sfx.finished
		soundPlaying = false
	queue_free()
