extends Node2D
class_name RoundManager


# Tracks when all waves of this round have been spawned
var RoundDone: bool = false
# Current round/level number
var LevelNumber: int = 1

# Preload your enemy scenes for performance and null-checks
@onready var zombie_scene: PackedScene = preload("res://scenes/enemy.tscn")
@onready var bat_scene:    PackedScene = preload("res://scenes/spooky_bat.tscn")
# Cache the Player node (assumes RoundManager and Player share the same parent)
@onready var player: Node2D = get_parent().get_node("Player")

func _ready() -> void:
	# Sanity: ensure both scenes loaded
	if zombie_scene == null:
		push_error("RoundManager: failed to preload 'enemy.tscn'")
		return
	if bat_scene == null:
		push_error("RoundManager: failed to preload 'spooky_bat.tscn'")
		return
		
	# Give the scene a moment to fully initialize
	await get_tree().create_timer(1.0).timeout
	# Begin the first round
	await start_round(LevelNumber)
	SaveData.RoundLevel = LevelNumber

func _process(delta: float) -> void:
	# Once all waves spawned and no enemies remain, advance to next round
	if RoundDone and get_child_count() == 0:
		LevelNumber += 1
		print("[RoundManager] Round done. Advancing to level %d" % LevelNumber)
		SaveData.RoundLevel = LevelNumber
		if LevelNumber > SaveData.MaxUnlockedLevel:
			SaveData.MaxUnlockedLevel = LevelNumber
		RoundDone = false
		await start_round(LevelNumber)

# Build metadata for this level’s spawns
func get_round_data(level: int) -> Array:
	var zombie_base = 5  + (level - 1) * 20
	var bat_base    = 3  + (level - 1) * 5
	var zombie_intv = 30.0
	var bat_intv    = 20.0
	var data = [
		{"type":"Zombie", "base":zombie_base, "interval":zombie_intv},
		{"type":"Bat",    "base":bat_base,    "interval":bat_intv}
	]
	print("[RoundManager] get_round_data(level=%d) -> %s" % [level, data])
	return data

# Main loop: spawn both types each wave, then wait
func start_round(level: int) -> void:
	print("[RoundManager] start_round(level=%d)" % level)
	await get_tree().create_timer(1.0).timeout  # initial delay

	var rd = get_round_data(level)
	var z_info = rd[0]
	var b_info = rd[1]
	var waves  = 20

	for wave in range(waves):
		var z_count = z_info.base + wave
		var b_count = b_info.base + wave

		print("[RoundManager]  Wave %d/%d — Zombies=%d, Bats=%d"
			  % [wave+1, waves, z_count, b_count])

		# Spawn both in the same iteration
		spawn_around_player("Zombie", z_count)
		spawn_around_player("Bat",    b_count)

		# Scale rewards/difficulty as you did before
		SaveData.CoinValue   = level + 0.05 * wave
		SaveData.DamageScale = level + 0.05 * wave

		# Wait the smaller of the two intervals so both spawn smoothly
		var delay = min(z_info.interval, b_info.interval)
		await get_tree().create_timer(delay).timeout

	RoundDone = true
	print("[RoundManager] Round %d complete" % level)


# Unified spawning for both enemy types
func spawn_around_player(enemy_type: String, count: int) -> void:
	if not is_instance_valid(player):
		push_error("RoundManager.spawn_around_player: Player invalid")
		return

	# pick the right scene
	var scene: PackedScene
	if enemy_type == "Zombie":
		scene = zombie_scene
	elif enemy_type == "Bat":
		scene = bat_scene
	else:
		push_error("RoundManager.spawn_around_player: no scene for '%s'" % enemy_type)
		return

	var center = player.global_position

	for i in range(count):
		var inst = scene.instantiate() as Node2D
		var angle = randf_range(0, TAU)
		var offset = Vector2.ZERO

		if enemy_type == "Zombie":
			offset = Vector2(cos(angle), sin(angle)) * 1500.0
		else:
			var radius = randf_range(1000.0, 1500.0)
			offset = Vector2(cos(angle), sin(angle)) * radius + Vector2(0, -200)

		inst.global_position = center + offset
		add_child(inst)
