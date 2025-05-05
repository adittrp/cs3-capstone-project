extends CharacterBody2D
class_name Player

signal died

@onready var camera_remote_transform = $CameraRemoteTransform
<<<<<<< Updated upstream
=======
@onready var hitbox = $Hitbox/PlayerCollider
@onready var secondaryCollider = $CollisionShape2D

@export var step_interval: float = 0.4   # seconds between steps
@export var contact_damage_interval: float = 0.5

var _step_timer: float = 0.0
>>>>>>> Stashed changes

var curHealth: float
var invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var enemies_inside := []

# Upgradables
var maxHealth: int = 100
var shotPower: int = 20
var movSpeed: float = 500.0
var shotSpeed: float = 0.4
var armor: float = 0
var regeneration: float = 0.1
var magnet: float = 0
var coinMultiplier: float = 1

var healthUpgradeLevel: int = 5
var shotPowerUpgradeLevel: int = 0
var movSpeedUpgradeLevel: int = 0
var shotSpeedUpgradeLevel: int = 0
var armorUpgradeLevel: int = 5
var regenerationUpgradeLevel: int = 0
var magnetUpgradeLevel: int = 0
var coinMultiplierUpgradeLevel: int = 0

var bullet_scene = preload("res://scenes/bullet.tscn")
var canShoot = true

func _ready() -> void:
	maxHealth = 100 + (25 * healthUpgradeLevel)
	curHealth = maxHealth

	update_health_ui()
	regenHealth()
	contact_damage_loop()

func _process(delta):
<<<<<<< Updated upstream
	# Upgrade things
	maxHealth = 100 + (25 * healthUpgradeLevel)
	shotPower = int(20 * (1 + float(shotPowerUpgradeLevel)/3))
	movSpeed = 500 + (50 * float(movSpeedUpgradeLevel))
	shotSpeed = 1.0 - (0.1 * float(shotSpeedUpgradeLevel))
	if shotSpeed <= 0.2:
		shotSpeed = 0.3
	
	armor = 1 + (0.25 * float(armorUpgradeLevel))
	regeneration = 0.1 + (0.15 * float(regenerationUpgradeLevel))
	magnet = 1 + (0.25 * float(magnetUpgradeLevel))
	coinMultiplier = (1.5 * float(coinMultiplierUpgradeLevel))
	
	
	
=======
	# Upgrade stats every frame
	maxHealth = 100 + (25 * SaveData.healthUpgradeLevel)
	shotPower = int(20 * (1 + float(SaveData.shotPowerUpgradeLevel)/3))
	movSpeed = 500 + (50 * float(SaveData.moveSpeedUpgradeLevel))
	shotSpeed = 1.0 - (0.1 * float(SaveData.shotSpeedUpgradeLevel))
	if shotSpeed <= 0.2:
		shotSpeed = 0.3

	armor = 1 + (0.25 * float(SaveData.armorUpgradeLevel))
	regeneration = 0.1 + (0.15 * float(SaveData.regenerationUpgradeLevel))

>>>>>>> Stashed changes
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and canShoot:
		shoot()
		$GunShot.play()
		canShoot = false
		await get_tree().create_timer(shotSpeed).timeout
		canShoot = true
<<<<<<< Updated upstream
		
	if invulnerable:
		await get_tree().create_timer(0.5).timeout
		invulnerable = false

	
=======

	# Footstep SFX
	var is_moving := velocity.length() > 0.1
	if is_moving:
		_step_timer += delta
		if _step_timer >= step_interval:
			$FootStep.play()
			_step_timer = 0.0
	else:
		_step_timer = step_interval

>>>>>>> Stashed changes
func regenHealth():
	await get_tree().create_timer(1).timeout
	if curHealth < maxHealth:
		curHealth += regeneration
		curHealth = min(curHealth, maxHealth)
	update_health_ui()
	regenHealth()

func shoot():
	var bullet = bullet_scene.instantiate()
	var shoot_direction = (get_global_mouse_position() - global_position).normalized()
	var spawn_offset = shoot_direction * 30

	bullet.global_position = global_position + spawn_offset
	bullet.direction = shoot_direction
	bullet.rotation = shoot_direction.angle()
	bullet.shotPower = shotPower
<<<<<<< Updated upstream
	
=======

>>>>>>> Stashed changes
	get_tree().current_scene.add_child(bullet)

func _physics_process(delta):
	var direction := Vector2.ZERO
	
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
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000 * delta)

# ───────────────────────────────────────────────────────────────
# Overlap-Based Damage System
func _on_hitbox_body_entered(body: Node2D) -> void:
<<<<<<< Updated upstream
	if body is Enemy and !invulnerable:
		print("Enemy hit player")
		curHealth -= 20 / armor
		
		if curHealth < 0: 
			curHealth = 0
		body.stopped()
		
		update_health_ui()
		invulnerable = true
		
		# Apply knockback direction and force
		var knockback_dir = (global_position - body.global_position).normalized()
		knockback_velocity = knockback_dir * 550
		
	if curHealth <= 0:
		died.emit()
		queue_free()
=======
	if body is Enemy and body not in enemies_inside:
		enemies_inside.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body in enemies_inside:
		enemies_inside.erase(body)

func contact_damage_loop() -> void:
	while true:
		await get_tree().create_timer(contact_damage_interval).timeout

		if enemies_inside.size() > 0 and !invulnerable:
			curHealth -= 20 / armor
			curHealth = max(curHealth, 0)

			update_health_ui()
			invulnerable = true
			hitbox.disabled = true
			secondaryCollider.disabled = true

			var first_enemy = enemies_inside[0]
			var knockback_dir = (global_position - first_enemy.global_position).normalized()
			knockback_velocity = knockback_dir * 600

			if curHealth <= 0:
				died.emit()
				queue_free()

			await get_tree().create_timer(0.3).timeout
			invulnerable = false
			hitbox.disabled = false
			secondaryCollider.disabled = false
# ───────────────────────────────────────────────────────────────
>>>>>>> Stashed changes

func update_health_ui():
	var health_bar = get_node("/root/World/UI/HealthBar")
	var health_label = get_node("/root/World/UI/HealthLabel")
<<<<<<< Updated upstream

	health_bar.value = curHealth
	
	var formatted = "%.0f" % curHealth
	health_label.text = formatted + " HP"
=======
	health_bar.value = curHealth / maxHealth * 100
	health_label.text = "%.0f/%d HP" % [curHealth, maxHealth]
>>>>>>> Stashed changes
