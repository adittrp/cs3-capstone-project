extends Control

@onready var ability_list = $TabContainer/Abilities/ScrollContainer/AbilityList
@onready var skill_list = $TabContainer/Skills/ScrollContainer/SkillList
@onready var detail_panel = $DetailPanel
@onready var cover_panel = $DetailPanel/CoverPanel
@onready var upgrade_button = $DetailPanel/UpgradeButtonWrapper/Button
@onready var back_button = $ExitButton

var ability_entry_scene = preload("res://upgrade_screen_folder/ability_entry.tscn")
var skill_entry_scene = preload("res://upgrade_screen_folder/skills_entry.tscn") # new
var selected_thing_name := ""


var test_skills = [
	{
		"name": "Shoot Power",
		"icon": preload("res://upgrade_screen_folder/images/ChatGPT Image Apr 20, 2025, 08_36_18 PM.png"),
		"desc": "Increases the raw damage output of your weapon per shot. Useful for taking down tougher enemies more efficiently in later stages. Higher shoot power is essential for burst damage builds and clearing out enemies before they can close in."
	},
	{
		"name": "Move Speed",
		"icon": preload("res://upgrade_screen_folder/images/movespeed-removebg-preview.png"),
		"desc": "Boosts your movement speed, allowing you to dodge projectiles, outrun enemies, and navigate the map with more control and fluidity. Movement upgrades are vital for evasion-based builds or any player relying on hit-and-run tactics."
	},
	{
		"name": "Shoot Speed",
		"icon": preload("res://upgrade_screen_folder/images/shootspeed-removebg-preview.png"),
		"desc": "Reduces the time between shots, increasing your overall fire rate. Great for crowd control and maximizing DPS in high-stress situations where timing matters. Works best when paired with other offensive upgrades like multi-projectile effects."
	},
	{
		"name": "Health Regeneration",
		"icon": preload("res://upgrade_screen_folder/images/regen-removebg-preview.png"),
		"desc": "Slowly regenerates your health over time. Especially useful during longer runs where healing items are limited or unavailable. Combos well with defensive abilities and armor upgrades for sustained survivability without relying on pickups."
	},
	{
		"name": "Coin Magnet Strength",
		"icon": preload("res://upgrade_screen_folder/images/magnet-removebg-preview.png"),
		"desc": "Increases the radius at which coins and loot are pulled toward you, making collection easier and allowing you to stay mobile while gathering. Great for farming builds or anyone who prefers to keep moving without doubling back for pickups."
	},
	{
		"name": "Armor Plating",
		"icon": preload("res://upgrade_screen_folder/images/armor-removebg-preview.png"),
		"desc": "Reinforces your character with an extra layer of reactive plating, reducing incoming damage from physical and projectile sources. This upgrade is essential for surviving tougher enemy waves and bosses that rely on rapid burst damage. Its benefits stack well with health regeneration to create a tankier build overall."
	},
	{
		"name": "Max Health Increase",
		"icon": preload("res://upgrade_screen_folder/images/maxhealth-removebg-preview.png"),
		"desc": "Expands your maximum health pool, letting you withstand more damage before requiring healing. Crucial for durability-focused builds and enduring boss mechanics without relying solely on regeneration."
	},
	{
		"name": "Coin Multiplier",
		"icon": preload("res://upgrade_screen_folder/images/coinmultiplier-removebg-preview.png"),
		"desc": "Applies a multiplier to all coins collected, boosting your currency gains from enemies and pickups. Ideal for players aiming to rapidly amass resources for upgrades and shop purchases."
	}
]

var test_abilities = [
	{
		"name": "Dash",
		"icon": preload("res://upgrade_screen_folder/images/exampleicon.jpg"),
		"level": 1,
		"stat": 1.5,
		"next_stat": 2.0,
		"cost": 60,
		"desc": "Grants the player a quick dash move to evade enemies or reposition. The dash distance and speed improve with each upgrade, allowing tighter movement in combat situations."
	},
	{
		"name": "Hypnosis Power",
		"icon": preload("res://upgrade_screen_folder/images/exampleicon.jpg"),
		"level": 1,
		"stat": 3,
		"next_stat": 5,
		"cost": 90,
		"desc": "Releases a burst of hypnotic energy that temporarily stuns nearby enemies. Increasing its level improves range and duration, making it a powerful tool for crowd control or escape."
	},
	{
		"name": "Time Slow",
		"icon": preload("res://upgrade_screen_folder/images/exampleicon.jpg"),
		"level": 1,
		"stat": 0.5,
		"next_stat": 0.65,
		"cost": 100,
		"desc": "Temporarily slows down time during activation, giving you a speed and awareness advantage. Each upgrade increases the effect's duration and reduces its cooldown."
	}
]

func _ready():

	# Load Abilities
	for data in test_abilities:
		var entry = ability_entry_scene.instantiate()
		entry.set_data(data)
		entry.ability_selected.connect(_on_ability_selected)
		ability_list.add_child(entry)

	# Load Skills
	for data in test_skills:
		var entry = skill_entry_scene.instantiate()
		entry.set_data(data)
		entry.skill_selected.connect(_on_skill_selected)
		skill_list.add_child(entry)
		
	# connect button press
	upgrade_button.pressed.connect(button_pressed)

func _on_ability_selected(data: Dictionary):
	selected_thing_name = data.name
	_update_detail_panel(data)
	fade_away_cover()

func _on_skill_selected(data: Dictionary):
	selected_thing_name = data.name
	_update_detail_panel(data)
	fade_away_cover()

func _update_detail_panel(data: Dictionary):
	var Name = data.name
	
	SaveData.save_game()
	var level = SaveData.skillLevels[Name]
	var current_and_next_stat_calculation_dict = calculate_stat_values(Name)
	var current_cost = SaveData.skillLevelPrices[Name][0] * (SaveData.skillLevelPrices[Name][1] ** level)
	
	$DetailPanel/IconWrapper/Icon.texture = data.icon
	$DetailPanel/LabelLevelWrapper/LevelLabel.text = "Level: %d" % level
	$DetailPanel/CurrentStatWrapper/Label.text = "Current: %s" % str(float(current_and_next_stat_calculation_dict["current"]))
	$DetailPanel/NextStatWrapper/NextStatLabel.text = "Next: %s" % str(float(current_and_next_stat_calculation_dict["next"]))
	$DetailPanel/CostWrapper/CostLabel.text = "Cost: %d" % current_cost
	$DetailPanel/DescriptionWrapper/TitleLabel.text = data.name
	$DetailPanel/DescriptionWrapper/SmallDescriptionLabel.text = data.desc

func button_pressed():
	if selected_thing_name == "":
		print("gurt")
		return
	var level = SaveData.skillLevels.get(selected_thing_name, 0)
	var cost = SaveData.skillLevelPrices[selected_thing_name][0] * (SaveData.skillLevelPrices[selected_thing_name][1] ** level)
	
	if SaveData.coins >= cost:
		# Deduct coins and level up
		SaveData.coins -= cost
		SaveData.skillLevels[selected_thing_name] = level + 1
		
		# Update the correct upgrade variable
		match selected_thing_name:
			"Max Health Increase": SaveData.healthUpgradeLevel += 1
			"Shoot Power": SaveData.shotPowerUpgradeLevel += 1
			"Move Speed": SaveData.moveSpeedUpgradeLevel += 1
			"Shoot Speed": SaveData.shotSpeedUpgradeLevel += 1
			"Armor Plating": SaveData.armorUpgradeLevel += 1
			"Health Regeneration": SaveData.regenerationUpgradeLevel += 1
			"Coin Magnet Strength": SaveData.magnetUpgradeLevel += 1
			"Coin Multiplier": SaveData.coinMultiplierUpgradeLevel += 1
			_: print("not supported yet")
		# Save updated data
		await SaveData.save_game()

		# Update detail panel with new stats
		var updated_data = test_skills.filter(func(d): return d.name == selected_thing_name)[0]
		_update_detail_panel(updated_data)
	else:
		print("Not enough coins!")
	

func fade_away_cover():
	var tween = create_tween()

	var starting_color: Color = cover_panel.modulate
	var ending_color: Color = starting_color
	ending_color.a = 0.0  # target alpha (fully transparent)
	
	# Tween the modulate property over 0.5 seconds
	tween.tween_property(cover_panel,"modulate",ending_color,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# After the fade is done, hide the panel
	tween.finished.connect(func(): cover_panel.visible = false)

func calculate_stat_values(upgrade_name: String) -> Dictionary:
	var current := 0.0
	var next := 0.0
	
	match upgrade_name:
		"Max Health Increase":
			current = 100 + (25 * SaveData.healthUpgradeLevel)
			next = 100 + (25 * (SaveData.healthUpgradeLevel + 1))
		
		"Shoot Power":
			current = int(20 * (1 + float(SaveData.shotPowerUpgradeLevel) / 3))
			next = int(20 * (1 + float(SaveData.shotPowerUpgradeLevel + 1) / 3))
		
		"Move Speed":
			current = 500 + (50 * SaveData.moveSpeedUpgradeLevel)
			next = 500 + (50 * (SaveData.moveSpeedUpgradeLevel + 1))
		
		"Shoot Speed":
			current = max(1.0 - (0.1 * SaveData.shotSpeedUpgradeLevel), 0.3)
			next = max(1.0 - (0.1 * (SaveData.shotSpeedUpgradeLevel + 1)), 0.3)
		
		"Armor Plating":
			current = 1 + (0.25 * SaveData.armorUpgradeLevel)
			next = 1 + (0.25 * (SaveData.armorUpgradeLevel + 1))
		
		"Health Regeneration":
			current = 0.1 + (0.15 * SaveData.regenerationUpgradeLevel)
			next = 0.1 + (0.15 * (SaveData.regenerationUpgradeLevel + 1))
		
		"Coin Magnet Strength":
			current = 1.25 + 0.65 * float(SaveData.magnetUpgradeLevel)
			next = 1.25 + 0.65 * float(SaveData.magnetUpgradeLevel + 1)
		
		"Coin Multiplier":
			current = 1 + int(1.5 * (SaveData.coinMultiplierUpgradeLevel))
			next = 1 + int(1.5 * (SaveData.coinMultiplierUpgradeLevel + 1))
		
		_:
			push_error("Invalid upgrade name: " + upgrade_name)
	
	return {
		"current": current,
		"next": next
	}
