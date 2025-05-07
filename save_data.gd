extends Node

# --- Upgrade levels ---
var healthUpgradeLevel: int = 0
var shotPowerUpgradeLevel: int = 0
var moveSpeedUpgradeLevel: int = 0
var shotSpeedUpgradeLevel: int = 0
var armorUpgradeLevel: int = 0
var regenerationUpgradeLevel: int = 0
var magnetUpgradeLevel: int = 0
var coinMultiplierUpgradeLevel: int = 0
var dashUpgradeLevel: int = 0
var hypnosisPowerUpgradeLevel: int = 0
var timeSlowUpgradeLevel: int = 0

# --- Currency ---
var coins: int = 0

# --- Mirror for UI code ---
var skillLevels = {
	"Max Health Increase": healthUpgradeLevel,
	"Shoot Power": shotPowerUpgradeLevel,
	"Move Speed": moveSpeedUpgradeLevel,
	"Shoot Speed": shotSpeedUpgradeLevel,
	"Armor Plating": armorUpgradeLevel,
	"Health Regeneration": regenerationUpgradeLevel,
	"Coin Magnet Strength": magnetUpgradeLevel,
	"Coin Multiplier": coinMultiplierUpgradeLevel,
	"Dash": dashUpgradeLevel,
	"Hypnosis Power": hypnosisPowerUpgradeLevel,
	"Time Slow": timeSlowUpgradeLevel
}

var skillLevelPrices = {
	"Max Health Increase": [20, 1.1],
	"Shoot Power": [20, 1.1],
	"Move Speed": [15, 1.5],
	"Shoot Speed": [50, 1.5],
	"Armor Plating": [25, 1.2],
	"Health Regeneration": [25, 1.5],
	"Coin Magnet Strength": [40, 1.25],
	"Coin Multiplier": [25, 1.25],
	"Dash": [0, 0],
	"Hypnosis Power": [0, 0],
	"Time Slow": [0, 0]
}

var CoinValue : int = 1
var DamageScale : int = 1
var RoundLevel : int = 1

func _ready():
	# Give the rest of the tree a chance to initialize
	await get_tree().create_timer(0.3).timeout
	load_data()
	update_skill_data()
	#coins += 1000000

# --- Save current state to disk ---
func save_game() -> void:
	# Build dictionary with *exact* keys that load_data expects:
	var save_data = {
		"healthUpgradeLevel": healthUpgradeLevel,
		"shotPowerUpgradeLevel": shotPowerUpgradeLevel,
		"moveSpeedUpgradeLevel": moveSpeedUpgradeLevel,
		"shotSpeedUpgradeLevel": shotSpeedUpgradeLevel,
		"armorUpgradeLevel": armorUpgradeLevel,
		"regenerationUpgradeLevel": regenerationUpgradeLevel,
		"magnetUpgradeLevel": magnetUpgradeLevel,
		"coinMultiplierUpgradeLevel": coinMultiplierUpgradeLevel,
		"dashUpgradeLevel": dashUpgradeLevel,
		"hypnosisPowerUpgradeLevel": hypnosisPowerUpgradeLevel,
		"timeSlowUpgradeLevel": timeSlowUpgradeLevel,
		"coins": coins
	}

	var save_file = FileAccess.open("user://upgradeData.save", FileAccess.WRITE)
	save_file.store_var(save_data)
	save_file.close()

	# Now that disk is updated, just refresh our in-memory mirror:
	update_skill_data()

# --- Load on disk state back into memory ---
func load_data() -> void:
	if not FileAccess.file_exists("user://upgradeData.save"):
		return  # nothing to load yet

	var save_file = FileAccess.open("user://upgradeData.save", FileAccess.READ)
	var save_data = save_file.get_var()
	save_file.close()

	# Pull out each value by the exact matching key:
	healthUpgradeLevel            = save_data.get("healthUpgradeLevel", 0)
	shotPowerUpgradeLevel         = save_data.get("shotPowerUpgradeLevel", 0)
	moveSpeedUpgradeLevel          = save_data.get("moveSpeedUpgradeLevel", 0)
	shotSpeedUpgradeLevel         = save_data.get("shotSpeedUpgradeLevel", 0)
	armorUpgradeLevel             = save_data.get("armorUpgradeLevel", 0)
	regenerationUpgradeLevel      = save_data.get("regenerationUpgradeLevel", 0)
	magnetUpgradeLevel            = save_data.get("magnetUpgradeLevel", 0)
	coinMultiplierUpgradeLevel    = save_data.get("coinMultiplierUpgradeLevel", 0)
	dashUpgradeLevel              = save_data.get("dashUpgradeLevel", 0)
	hypnosisPowerUpgradeLevel     = save_data.get("hypnosisPowerUpgradeLevel", 0)
	timeSlowUpgradeLevel          = save_data.get("timeSlowUpgradeLevel", 0)
	coins                         = save_data.get("coins", 0)

# --- Refresh the mirror dictionary your UI code uses ---
func update_skill_data() -> void:
	skillLevels = {
		"Max Health Increase": healthUpgradeLevel,
		"Shoot Power": shotPowerUpgradeLevel,
		"Move Speed": moveSpeedUpgradeLevel,
		"Shoot Speed": shotSpeedUpgradeLevel,
		"Armor Plating": armorUpgradeLevel,
		"Health Regeneration": regenerationUpgradeLevel,
		"Coin Magnet Strength": magnetUpgradeLevel,
		"Coin Multiplier": coinMultiplierUpgradeLevel,
		"Dash": dashUpgradeLevel,
		"Hypnosis Power": hypnosisPowerUpgradeLevel,
		"Time Slow": timeSlowUpgradeLevel
	}
	
func reset():
	healthUpgradeLevel            = 0
	shotPowerUpgradeLevel         = 0
	moveSpeedUpgradeLevel         = 0
	shotSpeedUpgradeLevel         = 0
	armorUpgradeLevel             = 0
	regenerationUpgradeLevel      = 0
	magnetUpgradeLevel            = 0
	coinMultiplierUpgradeLevel    = 0
	dashUpgradeLevel              = 0
	hypnosisPowerUpgradeLevel     = 0
	timeSlowUpgradeLevel          = 0
	coins                         = 0
