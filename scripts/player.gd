extends CharacterBody2D
class_name Player

signal died

@onready var camera_remote_transform = $CameraRemoteTransform
@onready var hitbox = $Hitbox/PlayerCollider
@onready var secondaryCollider = $CollisionShape2D
#footstep stuff

@export var step_interval: float = 0.4   # seconds between steps
var _step_timer: float = 0.0

var curHealth: float
var invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

# Upgradables
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

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	SaveData.load_data()
	maxHealth = 100 + (25 * SaveData.healthUpgradeLevel)
	curHealth = maxHealth
	
	update_health_ui()
	regenHealth()

func _process(delta):
	# Upgrade things
	maxHealth = 100 + (25 * SaveData.healthUpgradeLevel)
	shotPower = int(20 * (1 + float(SaveData.shotPowerUpgradeLevel)/3))
	movSpeed = 500 + (50 * float(SaveData.moveSpeedUpgradeLevel))
	shotSpeed = 1.0 - (0.1 * float(SaveData.shotSpeedUpgradeLevel))
	if shotSpeed <= 0.2:
		shotSpeed = 0.3
	
	armor = 1 + (0.25 * float(SaveData.armorUpgradeLevel))
	regeneration = 0.1 + (0.15 * float(SaveData.regenerationUpgradeLevel))
	
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and canShoot:
		shoot()
		$GunShot.play()
		canShoot = false
		await get_tree().create_timer(shotSpeed).timeout
		canShoot = true
		
	if invulnerable:
		await get_tree().create_timer(0.5).timeout
		invulnerable = false
		
		hitbox.disabled = false
		secondaryCollider.disabled = false
	
	# ─── Footstep SFX ─────────────────────────────────────────────────────────
	var is_moving := velocity.length() > 0.1
	if is_moving:
		_step_timer += delta
		if _step_timer >= step_interval:
			$FootStep.play()
			_step_timer = 0.0
	else:
		# reset so the very first step plays immediately on start
		_step_timer = step_interval
	# ─────────────────────────────────────────────────────────────────────────
	
func regenHealth():
	await get_tree().create_timer(1).timeout
	if curHealth < maxHealth:
		curHealth += regeneration
	regenHealth()
	update_health_ui()

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	var shoot_direction = (get_global_mouse_position() - global_position).normalized()
	
	var spawn_offset = shoot_direction * 30  # Tune this distance as needed
	bullet.global_position = global_position + spawn_offset
	
	bullet.direction = shoot_direction
	bullet.rotation = shoot_direction.angle()
	
	bullet.shotPower = shotPower
	get_tree().current_scene.add_child(bullet)
	
func _physics_process(delta):
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
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1000 * delta)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy and !invulnerable:
		print("Enemy hit player")
		curHealth -= 20 / armor
		
		if curHealth < 0: 
			curHealth = 0
		body.stopped()
		
		update_health_ui()
		invulnerable = true
		
		hitbox.disabled = true
		
		# Apply knockback direction and force
		var knockback_dir = (global_position - body.global_position).normalized()
		knockback_velocity = knockback_dir * 550
		
	if curHealth <= 0:
		died.emit()
		queue_free()

func update_health_ui():
	var health_bar = get_node("/root/World/UI/HealthBar")
	var health_label = get_node("/root/World/UI/HealthLabel")

	health_bar.value = curHealth/maxHealth * 100
	
	var formatted = "%.0f" % curHealth
	health_label.text = formatted + "/" + str(maxHealth) + " HP"
