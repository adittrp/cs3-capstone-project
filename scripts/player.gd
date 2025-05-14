extends CharacterBody2D
class_name Player

signal died

@onready var camera_remote_transform = $CameraRemoteTransform
@onready var hitbox = $Hitbox/PlayerCollider
@onready var secondaryCollider = $CollisionShape2D

# Configurable stat intervals
@export var step_interval: float = 0.4
@export var contact_damage_interval: float = 0.1

var _step_timer: float = 0.0
var gun_selected: String = "Shotgun"

# Core player values
var curHealth: float
var invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
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

# ammo feature + reload variables
var pistol_ammo: int = 15
var pistol_max_ammo: int = 15
var shotgun_ammo: int = 7
var shotgun_max_ammo: int = 7
var is_reloading: bool = false
@onready var reload_sound = preload("res://assets/gunreload.mp3")


func _input(event):
	
	
	
	
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				gun_selected = "Shotgun"
				update_gun_and_ammo_ui()
			KEY_2:
				gun_selected = "Pistol"
				update_gun_and_ammo_ui()
			KEY_R:
				if not is_reloading:
					reload_weapon()

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	SaveData.load_data()

	maxHealth = 100 + (25 * SaveData.healthUpgradeLevel)
	curHealth = maxHealth
	update_health_ui()
	regenHealth()
	contact_damage_loop()
	update_gun_and_ammo_ui()

func _process(delta):
	maxHealth = 100 + (25 * SaveData.healthUpgradeLevel)
	shotPower = int(20 * (1 + float(SaveData.shotPowerUpgradeLevel) / 3))
	movSpeed = 500 + (50 * float(SaveData.moveSpeedUpgradeLevel))
	shotSpeed = 1.0 - (0.1 * float(SaveData.shotSpeedUpgradeLevel))
	if shotSpeed <= 0.2:
		shotSpeed = 0.3
	armor = 1 + (0.25 * float(SaveData.armorUpgradeLevel))
	regeneration = 0.1 + (0.05 * float(SaveData.regenerationUpgradeLevel))

	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and canShoot and not invincible and not is_reloading and has_ammo():
		shoot()
		$GunShot.play()
		canShoot = false
		await get_tree().create_timer(shotSpeed).timeout
		canShoot = true

	var is_moving := velocity.length() > 0.1
	if is_moving:
		_step_timer += delta
		if _step_timer >= step_interval:
			$FootStep.play()
			_step_timer = 0.0
	else:
		_step_timer = step_interval

func regenHealth():
	await get_tree().create_timer(1).timeout
	if curHealth < maxHealth:
		curHealth += regeneration
		curHealth = min(curHealth, maxHealth)
	update_health_ui()
	regenHealth()

func shoot():
	
	if gun_selected == "Pistol":
		if pistol_ammo <= 0: return 
		pistol_ammo -= 1
	elif gun_selected == "Shotgun":
		if shotgun_ammo <= 0: return 
		shotgun_ammo -= 1
	
	
	if gun_selected == "Pistol":
		var bullet = bullet_scene.instantiate()
		var dir = (get_global_mouse_position() - global_position).normalized()
		bullet.global_position = global_position + dir * 30
		bullet.direction = dir
		bullet.rotation = dir.angle()
		bullet.shotPower = shotPower
		get_tree().current_scene.add_child(bullet)
		bullet.bullet_lifetime(2.0)
	elif gun_selected == "Shotgun":
		var randCount = randi_range(4, 6)
		var spreadCone = 20.0
		var base = (get_global_mouse_position() - global_position).normalized()
		for i in range(randCount):
			var bullet = bullet_scene.instantiate()
			var spread = randf_range(-(spreadCone/2) + (spreadCone/randCount)*i,
									  -(spreadCone/2) + (spreadCone/randCount)*(i+1))
			var dir2 = base.rotated(deg_to_rad(spread))
			bullet.global_position = global_position + dir2 * 10
			bullet.direction = dir2
			bullet.rotation = dir2.angle()
			bullet.shotPower = shotPower / 2.5
			get_tree().current_scene.add_child(bullet)
			bullet.bullet_lifetime(randf_range(0.1, 0.2))
	
	update_gun_and_ammo_ui()

func _physics_process(delta):
	if not invincible:
		var dir := Vector2.ZERO
		if not invulnerable:
			if Input.is_action_pressed("move_up"):
				dir.y -= 1
			if Input.is_action_pressed("move_down"):
				dir.y += 1
			if Input.is_action_pressed("move_left"):
				dir.x -= 1
			if Input.is_action_pressed("move_right"):
				dir.x += 1
		dir = dir.normalized()
		velocity = dir * movSpeed + knockback_velocity
		move_and_slide()
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO,
															 1000 * delta)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if ((body is Enemy) or (body is SpookyBat)) and body not in enemies_inside:
		enemies_inside.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body in enemies_inside:
		enemies_inside.erase(body)

func contact_damage_loop() -> void:
	while true:
		await get_tree().create_timer(contact_damage_interval).timeout
		if enemies_inside.size() > 0 and not invulnerable and not invincible:
			curHealth -= (20 * SaveData.DamageScale) / armor
			curHealth = max(curHealth, 0)
			update_health_ui()

			invulnerable = true
			hitbox.disabled = true
			secondaryCollider.disabled = true

			var first_enemy = enemies_inside[0]
			knockback_velocity = (global_position
								  - first_enemy.global_position).normalized() * 600

			if curHealth <= 0:
				died.emit()
				queue_free()

			await get_tree().create_timer(0.1).timeout
			invulnerable = false
			hitbox.disabled = false
			secondaryCollider.disabled = false

func update_health_ui():
	var bar = get_node("/root/World/UI/HealthBar")
	var label = get_node("/root/World/UI/HealthLabel")
	bar.value = curHealth / maxHealth * 100
	label.text = "%.0f/%d HP" % [curHealth, maxHealth]

func reload_weapon():
	is_reloading = true
	canShoot = false
	
	if gun_selected == "Pistol":
		await play_reload_sound()
		pistol_ammo = pistol_max_ammo
	elif gun_selected == "Shotgun":
		await play_reload_sound()
		await play_reload_sound()
		await play_reload_sound()
		
		shotgun_ammo = shotgun_max_ammo
	
	is_reloading = false
	canShoot = true
	update_gun_and_ammo_ui()

func play_reload_sound():
	var sound = AudioStreamPlayer.new()
	sound.stream = reload_sound
	add_child(sound)
	sound.play()
	await sound.finished
	sound.queue_free()
	
func has_ammo():
	if gun_selected == "Pistol":
		return pistol_ammo > 0
	elif gun_selected == "Shotgun":
		return shotgun_ammo > 0
	
	return false
	
func update_gun_and_ammo_ui():
	var current_ammo_label = $"../UI/CurrentAmmo"
	var max_ammo_label = $"../UI/MaxAmmoForGun"

	if gun_selected == "Pistol":
		current_ammo_label.text = "%02d" % pistol_ammo
		max_ammo_label.text = "%02d" % pistol_max_ammo

		# Color logic
		if pistol_ammo == 0:
			current_ammo_label.add_theme_color_override("font_color", Color.RED)
		elif pistol_ammo <= 8:
			current_ammo_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			current_ammo_label.add_theme_color_override("font_color", Color.WHITE)

		# UI visibility
		$"../UI/SelectedShotGun".visible = false
		$"../UI/SelectedPistol".visible = true
		$"../UI/UnselectedPistol".visible = false
		$"../UI/UnselectedShotgun".visible = true

	elif gun_selected == "Shotgun":
		current_ammo_label.text = "%02d" % shotgun_ammo
		max_ammo_label.text = "%02d" % shotgun_max_ammo

		# Color logic
		if shotgun_ammo == 0:
			current_ammo_label.add_theme_color_override("font_color", Color.RED)
		elif shotgun_ammo <= 4:
			current_ammo_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			current_ammo_label.add_theme_color_override("font_color", Color.WHITE)

		# UI visibility
		$"../UI/SelectedShotGun".visible = true
		$"../UI/SelectedPistol".visible = false
		$"../UI/UnselectedPistol".visible = true
		$"../UI/UnselectedShotgun".visible = false



	
		
	
	
	
