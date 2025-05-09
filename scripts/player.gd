extends CharacterBody2D
class_name Player

signal died

@onready var camera_remote_transform = $CameraRemoteTransform
@onready var hitbox = $Hitbox/PlayerCollider
@onready var secondaryCollider = $CollisionShape2D

# Configurable stat intervals

# Delay between footstep sounds
@export var step_interval: float = 0.4
# How often contact damage ticks
@export var contact_damage_interval: float = 0.1

var _step_timer: float = 0.0

# Core player values
var curHealth: float
var invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

# Enemies currently touching the player the player
var enemies_inside := []

# Upgradable stats
var maxHealth: int = 100
var shotPower: int = 20
var movSpeed: float = 500.0
var shotSpeed: float = 0.4
var armor: float = 0
var regeneration: float = 0.1
var magnet: float = 0
var coinMultiplier: float = 1

var bullet_scene = preload("res://scenes/bullet.tscn")
var canShoot = true
var invincible = false

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	SaveData.load_data()

	# Scale stats from upgrades
	maxHealth = 100 + (25 * SaveData.healthUpgradeLevel)
	curHealth = maxHealth

	update_health_ui()
	
	# Start health regeneration loop
	regenHealth()
	
	# Start contact damage handling
	contact_damage_loop()

func _process(delta):
	# Continuously update stats
	maxHealth = 100 + (25 * SaveData.healthUpgradeLevel)
	shotPower = int(20 * (1 + float(SaveData.shotPowerUpgradeLevel)/3))
	movSpeed = 500 + (50 * float(SaveData.moveSpeedUpgradeLevel))
	shotSpeed = 1.0 - (0.1 * float(SaveData.shotSpeedUpgradeLevel))
	if shotSpeed <= 0.2:
		shotSpeed = 0.3  # Clamp lower bound

	armor = 1 + (0.25 * float(SaveData.armorUpgradeLevel))
	regeneration = 0.1 + (0.05 * float(SaveData.regenerationUpgradeLevel))

	# Face the mouse cursor
	look_at(get_global_mouse_position())

	# Debug exit
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Firing logic
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and canShoot and !invincible:
		shoot()
		$GunShot.play()
		canShoot = false
		await get_tree().create_timer(shotSpeed).timeout
		canShoot = true

	# Footstep sound timer
	var is_moving := velocity.length() > 0.1
	if is_moving:
		_step_timer += delta
		if _step_timer >= step_interval:
			$FootStep.play()
			_step_timer = 0.0
	else:
		_step_timer = step_interval

func regenHealth():
	# Loop to regenerate health over time
	await get_tree().create_timer(1).timeout
	if curHealth < maxHealth:
		curHealth += regeneration
		curHealth = min(curHealth, maxHealth)
	update_health_ui()
	regenHealth()  # Recurse to keep loop going

func shoot():
	# Spawn and shoot a bullet in mouse direction
	var bullet = bullet_scene.instantiate()
	var shoot_direction = (get_global_mouse_position() - global_position).normalized()
	var spawn_offset = shoot_direction * 30

	bullet.global_position = global_position + spawn_offset
	bullet.direction = shoot_direction
	bullet.rotation = shoot_direction.angle()
	bullet.shotPower = shotPower

	get_tree().current_scene.add_child(bullet)

func _physics_process(delta):
	if not invincible:
		var direction := Vector2.ZERO
		if !invulnerable:
			if Input.is_action_pressed("move_up"):
				direction.y -= 1
			if Input.is_action_pressed("move_down"):
				direction.y += 1
			if Input.is_action_pressed("move_left"):
				direction.x -= 1
			if Input.is_action_pressed("move_right"):
				direction.x += 1

		direction = direction.normalized()
		var player_velocity = direction * movSpeed
		velocity = player_velocity + knockback_velocity
		move_and_slide()

		# Gradually reduce knockback over time
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000 * delta)

# ───────────────────────────────────────────────────────────────
# Contact-based damage system (enemies inside hitbox)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy and body not in enemies_inside:
		enemies_inside.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body in enemies_inside:
		enemies_inside.erase(body)

func contact_damage_loop() -> void:
	while true:
		await get_tree().create_timer(contact_damage_interval).timeout

		if enemies_inside.size() > 0 and !invulnerable and !invincible:
			# Damage calculation scales with round and is reduced by armor
			curHealth -= (20 * SaveData.DamageScale) / armor
			curHealth = max(curHealth, 0)
			update_health_ui()

			# Temporary invulnerability and knockback
			invulnerable = true
			hitbox.disabled = true
			secondaryCollider.disabled = true

			var first_enemy = enemies_inside[0]
			var knockback_dir = (global_position - first_enemy.global_position).normalized()
			knockback_velocity = knockback_dir * 600

			# Check for death
			if curHealth <= 0:
				died.emit()
				queue_free()

			# Invulnerability timer
			await get_tree().create_timer(0.1).timeout
			invulnerable = false
			hitbox.disabled = false
			secondaryCollider.disabled = false

# ───────────────────────────────────────────────────────────────

func update_health_ui():
	# Updates both the health bar and text label
	var health_bar = get_node("/root/World/UI/HealthBar")
	var health_label = get_node("/root/World/UI/HealthLabel")
	health_bar.value = curHealth / maxHealth * 100
	health_label.text = "%.0f/%d HP" % [curHealth, maxHealth]
