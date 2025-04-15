extends CharacterBody2D
class_name Player

signal died

@onready var camera_remote_transform = $CameraRemoteTransform


var bullet_scene = preload("res://scenes/bullet.tscn")
var canShoot = true

func _process(delta):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and canShoot:
		shoot()
		canShoot = false
		await get_tree().create_timer(0.25).timeout
		canShoot = true
	
@export var speed := 500.0

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	var shoot_direction = (get_global_mouse_position() - global_position).normalized()
	
	var spawn_offset = shoot_direction * 30  # Tune this distance as needed
	bullet.global_position = global_position + spawn_offset
	
	bullet.direction = shoot_direction
	bullet.rotation = shoot_direction.angle()
	
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
	velocity = direction * speed
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		print("Enemy touched player hitbox!")
		died.emit()
		queue_free()
