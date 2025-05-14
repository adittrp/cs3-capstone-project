extends CharacterBody2D
class_name SpookyBat

# --- Stats & State ---
@export var speed: float        = 100.0
@export var max_health: int     = 100
var health: int
@export var damage: int         = 5
@export var attack_range: float = 40.0

# --- Nodes ---
@onready var sprite     = $AnimatedSprite2D
@onready var health_bar = $HealthBar/ProgressBar
@onready var player     = get_node("/root/World/Player")

# --- Internal flags ---
var can_attack: bool = true
var attacking:   bool = false

func _ready() -> void:
	# Register as an enemy so bullets can hit us
	add_to_group("Enemies")
	# Initialize health & UI
	health = max_health
	health_bar.max_value = max_health
	health_bar.value     = health
	sprite.play("fly_animation")

func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
		return

	# Movement / attack
	if not attacking and is_instance_valid(player):
		var to_player = player.global_position - global_position
		if to_player.length() <= attack_range and can_attack:
			start_attack()
		else:
			velocity = to_player.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func start_attack() -> void:
	attacking  = true
	can_attack = false
	velocity   = Vector2.ZERO
	sprite.play("attack_animation")

	await get_tree().create_timer(0.25).timeout
	if is_instance_valid(player):
		player.curHealth -= damage
	await get_tree().create_timer(0.5).timeout

	attacking  = false
	can_attack = true
	sprite.play("fly_animation")

# Called by Bullet.gd when a bullet hits this bat
func shot_at(dmg: int) -> void:
	health -= dmg
	health_bar.value = max(health, 0)
	if health <= 0:
		queue_free()
