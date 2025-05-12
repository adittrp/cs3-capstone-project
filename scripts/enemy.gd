#
#extends CharacterBody2D
#class_name Enemy
#
## Load coin scene to drop on death
#@onready var coin_scene = load("res://scenes/coin.tscn")
#
## References to game objects in the scene
#@onready var coinManager = get_parent().get_parent().get_node("CoinManager")
#@onready var player = get_parent().get_parent().get_node("Player")
#
## Movement and health settings
#var speed: float = randf_range(100, 175)
#var direction := Vector2.ZERO
#var max_health = 100
#var health: int = 100
#var cant_move: bool = false
#var wander_timer := 0.0
#
#@onready var health_bar = $HealthBar/ProgressBar
#
#var directions := [
	#Vector2.LEFT,
	#Vector2.RIGHT,
	#Vector2.UP,
	#Vector2.DOWN
#]
#
#func _ready() -> void:
	## Initialize health bar value
	#update_health_bar()
#
#func shot_at(shotPower):
	## Subtract damage from health
	#health -= shotPower
#
	#if health <= 0:
		## Drop coins based on round level
		#for i in range(SaveData.RoundLevel):
			#var coin = coin_scene.instantiate()
			#
			## Randomize coin spawn position slightly
			#var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
			#var spawn_position = global_position + offset
			#
			#coin.position = coinManager.to_local(spawn_position)
			#coinManager.add_child(coin)
		#
		## Remove enemy from scene
		#queue_free()
	#else:
		## Update health bar after taking damage
		#update_health_bar()
#
#func _process(_delta: float) -> void:
	## Turn toward movement direction if moving
	#if direction != Vector2.ZERO:
		#look_at(global_position + direction * 50)
#
#func _physics_process(_delta: float) -> void:
	#if cant_move:
		#return
#
	#if player:
		## Don’t chase the player if they're invincible
		#if player.invincible:
			#return
#
		#var to_player = player.global_position - global_position
#
		## Chase player if not too close
		#if to_player.length() > 20.0:
			#direction = to_player.normalized()
			#velocity = direction * speed
		#else:
			#direction = Vector2.ZERO
			#velocity = Vector2.ZERO
#
		#move_and_slide()
#
#func stopped():  
	## Temporarily freeze enemy movement (used for hitstun or effects)
	#cant_move = true
	#await get_tree().create_timer(0.3).timeout
	#cant_move = false
#
#func update_health_bar():
	## Keep health bar synced with current health
	#health_bar.value = health
	#health_bar.max_value = max_health



extends CharacterBody2D
class_name Enemy

# --- Scenes & Nodes ---
@onready var coin_scene  = load("res://scenes/coin.tscn")
@onready var coinManager = get_parent().get_parent().get_node("CoinManager")
@onready var player      = get_parent().get_parent().get_node("Player")
@onready var health_bar  = $HealthBar/ProgressBar

# --- Stats & State ---
var max_health := 100
var health     := max_health
var speed      := randf_range(100, 175)
var direction  := Vector2.RIGHT
var cant_move  := false   
var dead := false

# --- Steering Params ---
const ATTRACT_WEIGHT    := 2.0
const REPULSE_WEIGHT    := 3000.0
const RAY_LENGTH        := 64.0
const RAY_ANGLE_SPREAD  := 120
const RAY_COUNT         := 7
const MAX_TURN_RATE     := deg_to_rad(180)  

func _ready() -> void:
	update_health_bar()

func shot_at(shotPower: int) -> void:
	health -= shotPower
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

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		look_at(global_position + direction)

func _physics_process(delta: float) -> void:
	if cant_move:
		return
	if not player or player.invincible:
		return

	
	var to_player = player.global_position - global_position
	var attract_vec = to_player.normalized() * ATTRACT_WEIGHT

	
	var repulse_vec = Vector2.ZERO
	var base_angle = attract_vec.angle()
	for i in range(RAY_COUNT):
		var t = float(i) / float(RAY_COUNT - 1)
		var angle = base_angle + deg_to_rad(-RAY_ANGLE_SPREAD/2.0 + RAY_ANGLE_SPREAD * t)
		var ray_dir = Vector2(cos(angle), sin(angle))
		var params = PhysicsRayQueryParameters2D.new()
		params.from    = global_position
		params.to      = global_position + ray_dir * RAY_LENGTH
		params.exclude = [self]
		var hit = get_world_2d().direct_space_state.intersect_ray(params)
		if hit:
			var dist = (hit.position - global_position).length()
			if dist > 0:
				var strength = REPULSE_WEIGHT / pow(dist, 2)
				repulse_vec += (global_position - hit.position).normalized() * strength


	var steering = (attract_vec + repulse_vec).normalized()
	var max_turn = MAX_TURN_RATE * delta
	var angle_diff = direction.angle_to(steering)
	if abs(angle_diff) <= max_turn:
		direction = steering
	else:
		direction = direction.rotated(sign(angle_diff) * max_turn).normalized()

	
	velocity = direction * speed
	move_and_slide()

func stopped() -> void:
	cant_move = true
	await get_tree().create_timer(0.3).timeout
	cant_move = false

func update_health_bar() -> void:
	health_bar.value     = health
	health_bar.max_value = max_health
