extends Node

# Upgrade levels
var healthUpgradeLevel: int = 0
var shotPowerUpgradeLevel: int = 0
var moveSpeedUpgradeLevel: int = 0
var shotSpeedUpgradeLevel: int = 0
var armorUpgradeLevel: int = 0
var regenerationUpgradeLevel: int = 0
var magnetUpgradeLevel: int = 0
var coinMultiplierUpgradeLevel: int = 0

# Have not added yet
var dashUpgradeLevel: int = 0
var hypnosisPowerUpgradeLevel: int = 0
var timeSlowUpgradeLevel: int = 0

# Currency
var coins: int = 0

# Other
var MaxUnlockedLevel : int = 1

# Name to variable
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

# Skill upgrade prices [base value, exponential value]
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

# Coin value multiplier
var CoinValue : float = 1
# Damage scaling factor
var DamageScale : float = 1
# Current round level
var RoundLevel : int = 1

func _ready():
	# Initialize game state, load data, and set values
	await get_tree().create_timer(0.3).timeout
	load_data()
	update_skill_data()

# Save current state to disk
func save_game() -> void:
	# Build dictionary with exact keys that load_data expects:
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
		"coins": coins,
		"RoundLevel": RoundLevel,
		"MaxUnlockedLevel": MaxUnlockedLevel
	}

	var save_file = FileAccess.open("user://upgradeData.save", FileAccess.WRITE)
	
	# Save game data to file
	save_file.store_var(save_data)
	save_file.close()

	# Now that disk is updated, update the skills
	update_skill_data()

# Load saved game state from disk
func load_data() -> void:
	if not FileAccess.file_exists("user://upgradeData.save"):
		return

	var save_file = FileAccess.open("user://upgradeData.save", FileAccess.READ)
	
	# Get saved data
	var save_data = save_file.get_var()
	save_file.close()

	# Extract values from saved data and assign them
	healthUpgradeLevel = save_data.get("healthUpgradeLevel", 0)
	shotPowerUpgradeLevel = save_data.get("shotPowerUpgradeLevel", 0)
	moveSpeedUpgradeLevel = save_data.get("moveSpeedUpgradeLevel", 0)
	shotSpeedUpgradeLevel = save_data.get("shotSpeedUpgradeLevel", 0)
	armorUpgradeLevel = save_data.get("armorUpgradeLevel", 0)
	regenerationUpgradeLevel = save_data.get("regenerationUpgradeLevel", 0)
	magnetUpgradeLevel = save_data.get("magnetUpgradeLevel", 0)
	coinMultiplierUpgradeLevel = save_data.get("coinMultiplierUpgradeLevel", 0)
	dashUpgradeLevel = save_data.get("dashUpgradeLevel", 0)
	hypnosisPowerUpgradeLevel = save_data.get("hypnosisPowerUpgradeLevel", 0)
	timeSlowUpgradeLevel = save_data.get("timeSlowUpgradeLevel", 0)
	coins = save_data.get("coins", 0)
	RoundLevel = save_data.get("RoundLevel", 1)
	MaxUnlockedLevel = save_data.get("MaxUnlockedLevel", 1)
# Refresh the mirror dictionary used by the UI
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
	
func get_level():
	return RoundLevel

# Reset all upgrades and set coins to a high number for testing
func reset():
	healthUpgradeLevel = 0
	shotPowerUpgradeLevel = 0
	moveSpeedUpgradeLevel = 0
	shotSpeedUpgradeLevel = 0
	armorUpgradeLevel = 0
	regenerationUpgradeLevel = 0
	magnetUpgradeLevel = 0
	coinMultiplierUpgradeLevel = 0
	dashUpgradeLevel = 0
	hypnosisPowerUpgradeLevel = 0
	timeSlowUpgradeLevel = 0
	coins = 1000000
