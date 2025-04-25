extends Node

var healthUpgradeLevel: int = 0
var shotPowerUpgradeLevel: int = 0
var movSpeedUpgradeLevel: int = 0
var shotSpeedUpgradeLevel: int = 0
var armorUpgradeLevel: int = 0
var regenerationUpgradeLevel: int = 0
var magnetUpgradeLevel: int = 0
var coinMultiplierUpgradeLevel: int = 0

func save_game():
	await get_tree().create_timer(1).timeout
	var world_node = get_tree().get_root().get_node("World")
	var save_data = {
		"healthUpgradeLevel": healthUpgradeLevel,
		"shotPowerUpgradeLevel": shotPowerUpgradeLevel,
		"movSpeedUpgradeLevel": movSpeedUpgradeLevel,
		"shotSpeedUpgradeLevel": shotSpeedUpgradeLevel,
		"armorUpgradeLevel": armorUpgradeLevel,
		"regenerationUpgradeLevel": regenerationUpgradeLevel,
		"magnetUpgradeLevel": magnetUpgradeLevel,
		"coinMultiplierUpgradeLevel": coinMultiplierUpgradeLevel,
		"coins": world_node.coins
	}
	
	var save = FileAccess.open("user://upgradeData.save", FileAccess.WRITE)
	save.store_var(save_data)
	save.close()
	
	save_game()
	
func load_data():
	if FileAccess.file_exists("user://upgradeData.save"):
		var save = FileAccess.open("user://upgradeData.save", FileAccess.READ)
		var save_data = save.get_var()
		save.close()
		
		healthUpgradeLevel = save_data.get("healthUpgradeLevel", 0)
		shotPowerUpgradeLevel = save_data.get("shotPowerUpgradeLevel", 0)
		movSpeedUpgradeLevel = save_data.get("movSpeedUpgradeLevel", 0)
		shotSpeedUpgradeLevel = save_data.get("shotSpeedUpgradeLevel", 0)
		armorUpgradeLevel = save_data.get("armorUpgradeLevel", 0)
		regenerationUpgradeLevel = save_data.get("regenerationUpgradeLevel", 0)
		magnetUpgradeLevel = save_data.get("magnetUpgradeLevel", 0)
		coinMultiplierUpgradeLevel = save_data.get("coinMultiplierUpgradeLevel", 0)
		
		var world_node = get_tree().get_root().get_node("World")
		world_node.coins = save_data.get("coins", 0)
	
