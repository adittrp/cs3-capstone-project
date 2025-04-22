extends CharacterBody2D
class_name Player

signal died

@onready var camera_remote_transform = $CameraRemoteTransform

var curHealth: float = 100
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

var healthUpgradeLevel: int = 0
var shotPowerUpgradeLevel: int = 0
var movSpeedUpgradeLevel: int = 0
var shotSpeedUpgradeLevel: int = 0
var armorUpgradeLevel: int = 0
var regenerationUpgradeLevel: int = 0
var magnetUpgradeLevel: int = 0
var coinMultiplierUpgradeLevel: int = 0

var bullet_scene = preload("res://scenes/bullet.tscn")
var canShoot = true


func _process(delta):
	# Upgrade things
	maxHealth = 100 + (25 * healthUpgradeLevel)
	shotPower = int(20 * (1 + float(shotPowerUpgradeLevel)/3))
	movSpeed = 500 + (50 * float(movSpeedUpgradeLevel))
	shotSpeed = 1.0 - (0.1 * float(shotSpeedUpgradeLevel))
	if shotSpeed <= 0.2:
		shotSpeed = 0.3
	
	armor = 0.25 * float(armorUpgradeLevel)
	regeneration = 0.1 + (0.15 * float(regenerationUpgradeLevel))
	magnet = 1 + (0.25 * float(magnetUpgradeLevel))
	coinMultiplier = (1.5 * float(coinMultiplierUpgradeLevel))
	
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
		curHealth -= 20
		update_health_ui()
		invulnerable = true
		print(curHealth)
		
		# Apply knockback direction and force
		var knockback_dir = (global_position - body.global_position).normalized()
		knockback_velocity = knockback_dir * 500
		
	if curHealth <= 0:
		died.emit()
		queue_free()

func update_health_ui():
	var health_bar = get_node("/root/World/UI/HealthBar")
	var health_label = get_node("/root/World/UI/HealthLabel")

	health_bar.value = curHealth
	health_label.text = str(curHealth) + " HP"
