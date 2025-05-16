extends CharacterBody2D
class_name SpookyBat

# --- Stats & State ---
var damage: int         = 5
var max_health := 50
var health     := max_health
var speed      := randf_range(175, 250)
var direction  := Vector2.RIGHT
var cant_move  := false   
var dead := false
# --- Nodes ---
@onready var sprite     = $AnimatedSprite2D
@onready var health_bar = $HealthBar/ProgressBar

@onready var player     = get_node("/root/World/Player")
@onready var coin_scene  = load("res://scenes/coin.tscn")
@onready var coinManager = get_parent().get_parent().get_node("CoinManager")

var attacking: bool = true
var can_attack: bool = true

func _ready() -> void:
	# Initialize health & UI
	health = max_health
	update_health_bar()
	sprite.play("fly_animation")

func _physics_process(_delta: float) -> void:
	if cant_move:
		return

	if player:
		# Don’t chase the player if they're invincible
		if player.invincible:
			return

		var to_player = player.global_position - global_position

		# Chase player if not too close
		if to_player.length() > 20.0:
			direction = to_player.normalized()
			velocity = direction * speed
		else:
			direction = Vector2.ZERO
			velocity = Vector2.ZERO

		move_and_slide()
		
# Called by Bullet.gd when a bullet hits this bat
func shot_at(dmg: int) -> void:
	health -= dmg
	if health <= 0 and !dead:
		_drop_coins()
		dead = true
		queue_free()
	else:
		update_health_bar()

func _drop_coins() -> void:
	for i in range(SaveData.RoundLevel):
		var c = coin_scene.instantiate()
		var offset = Vector2(randf_range(-50,50), randf_range(-50,50))
		c.position = coinManager.to_local(global_position + offset)
		coinManager.add_child(c)
		
func update_health_bar() -> void:
	health_bar.value     = health
	health_bar.max_value = max_health
