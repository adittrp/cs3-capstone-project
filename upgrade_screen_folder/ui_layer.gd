extends Control

@onready var ability_list = $TabContainer/Abilities/ScrollContainer/AbilityList
@onready var skill_list = $TabContainer/Skills/ScrollContainer/SkillList
@onready var detail_panel = $DetailPanel
@onready var cover_panel = $DetailPanel/CoverPanel

var ability_entry_scene = preload("res://upgrade_screen_folder/ability_entry.tscn")
var skill_entry_scene = preload("res://upgrade_screen_folder/skills_entry.tscn") # new

	
var test_skills = [
	{
		"name": "Shoot Power",
		"icon": preload("res://upgrade_screen_folder/images/ChatGPT Image Apr 20, 2025, 08_36_18 PM.png"),
		"level": 1,
		"stat": 12,
		"next_stat": 14,
		"cost": 50,
		"desc": "Increases the raw damage output of your weapon per shot. Useful for taking down tougher enemies more efficiently in later stages. Higher shoot power is essential for burst damage builds and clearing out enemies before they can close in."
	},
	{
		"name": "Move Speed",
		"icon": preload("res://upgrade_screen_folder/images/movespeed-removebg-preview.png"),
		"level": 1,
		"stat": 10,
		"next_stat": 12,
		"cost": 40,
		"desc": "Boosts your movement speed, allowing you to dodge projectiles, outrun enemies, and navigate the map with more control and fluidity. Movement upgrades are vital for evasion-based builds or any player relying on hit-and-run tactics."
	},
	{
		"name": "Shoot Speed",
		"icon": preload("res://upgrade_screen_folder/images/shootspeed-removebg-preview.png"),
		"level": 1,
		"stat": 1.0,
		"next_stat": 1.3,
		"cost": 60,
		"desc": "Reduces the time between shots, increasing your overall fire rate. Great for crowd control and maximizing DPS in high-stress situations where timing matters. Works best when paired with other offensive upgrades like multi-projectile effects."
	},
	{
		"name": "Health Regeneration",
		"icon": preload("res://upgrade_screen_folder/images/regen-removebg-preview.png"),
		"level": 1,
		"stat": 0.5,
		"next_stat": 0.75,
		"cost": 80,
		"desc": "Slowly regenerates your health over time. Especially useful during longer runs where healing items are limited or unavailable. Combos well with defensive abilities and armor upgrades for sustained survivability without relying on pickups."
	},
	{
		"name": "Coin Magnet Strength",
		"icon": preload("res://upgrade_screen_folder/images/magnet-removebg-preview.png"),
		"level": 1,
		"stat": 100,
		"next_stat": 150,
		"cost": 30,
		"desc": "Increases the radius at which coins and loot are pulled toward you, making collection easier and allowing you to stay mobile while gathering. Great for farming builds or anyone who prefers to keep moving without doubling back for pickups."
	},
	{
		"name": "Armor Plating",
		"icon": preload("res://upgrade_screen_folder/images/armor-removebg-preview.png"),
		"level": 1,
		"stat": 5,
		"next_stat": 8,
		"cost": 70,
		"desc": "Reinforces your character with an extra layer of reactive plating, reducing incoming damage from physical and projectile sources. This upgrade is essential for surviving tougher enemy waves and bosses that rely on rapid burst damage. Its benefits stack well with health regeneration to create a tankier build overall."
	},
	{
		"name": "Max Health Increase",
		"icon": preload("res://upgrade_screen_folder/images/maxhealth-removebg-preview.png"),
		"level": 1,
		"stat": 100,
		"next_stat": 120,
		"cost": 55,
		"desc": "Expands your maximum health pool, letting you withstand more damage before requiring healing. Crucial for durability-focused builds and enduring boss mechanics without relying solely on regeneration."
	},
	{
		"name": "Coin Multiplier",
		"icon": preload("res://upgrade_screen_folder/images/coinmultiplier-removebg-preview.png"),
		"level": 1,
		"stat": 1.0,
		"next_stat": 1.25,
		"cost": 50,
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

func _on_ability_selected(data: Dictionary):
	_update_detail_panel(data)
	fade_away_cover()

func _on_skill_selected(data: Dictionary):
	_update_detail_panel(data)
	fade_away_cover()

func _update_detail_panel(data: Dictionary):
	var Name = data.name
	var level = SaveData.skillLevels[Name]
	
	$DetailPanel/IconWrapper/Icon.texture = data.icon
	$DetailPanel/LabelLevelWrapper/LevelLabel.text = "Level: %d" % level
	$DetailPanel/CurrentStatWrapper/Label.text = "Current: %s" % str(data.stat)
	$DetailPanel/NextStatWrapper/NextStatLabel.text = "Next: %s" % str(data.next_stat)
	$DetailPanel/CostWrapper/CostLabel.text = "Cost: %d" % data.cost
	$DetailPanel/DescriptionWrapper/TitleLabel.text = data.name
	$DetailPanel/DescriptionWrapper/SmallDescriptionLabel.text = data.desc

func fade_away_cover():
	var tween = create_tween()

	var starting_color: Color = cover_panel.modulate
	var ending_color: Color = starting_color
	ending_color.a = 0.0  # target alpha (fully transparent)
	
	# Tween the modulate property over 0.5 seconds
	tween.tween_property(cover_panel,"modulate",ending_color,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# After the fade is done, hide the panel
	tween.finished.connect(func(): cover_panel.visible = false)
