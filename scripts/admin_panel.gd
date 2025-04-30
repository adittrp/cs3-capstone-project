extends Control

# grab every control by its unique name anywhere under this node
@onready var health_spin      := find_child("health_spin", true, false) as SpinBox
@onready var shoot_spin       := find_child("shoot_spin", true, false) as SpinBox
@onready var move_spin        := find_child("move_spin", true, false) as SpinBox
@onready var shoot_speed_spin := find_child("shoot_speed_spin", true, false) as SpinBox
@onready var armor_spin       := find_child("armor_spin", true, false) as SpinBox
@onready var regen_spin       := find_child("regen_spin", true, false) as SpinBox
@onready var magnet_spin      := find_child("magnet_spin", true, false) as SpinBox
@onready var coin_mult_spin   := find_child("coin_mult_spin", true, false) as SpinBox
@onready var dash_spin        := find_child("dash_spin", true, false) as SpinBox
@onready var hypnosis_spin    := find_child("hypnosis_spin", true, false) as SpinBox
@onready var time_slow_spin   := find_child("time_slow_spin", true, false) as SpinBox
@onready var coins_spin       := find_child("coins_spin", true, false) as SpinBox

@onready var save_button      := find_child("SaveButton", true, false) as Button
@onready var close_button     := find_child("CloseButton", true, false) as Button

func _ready():
	# sanity-check
	for c in [health_spin, shoot_spin, move_spin, shoot_speed_spin, armor_spin,
			  regen_spin, magnet_spin, coin_mult_spin, dash_spin, hypnosis_spin,
			  time_slow_spin, coins_spin, save_button, close_button]:
		if c == null:
			push_error("AdminPanel: missing node '" + str(c) + "'")

	# populate from SaveData
	health_spin.value      = SaveData.healthUpgradeLevel
	shoot_spin.value       = SaveData.shotPowerUpgradeLevel
	move_spin.value        = SaveData.movSpeedUpgradeLevel
	shoot_speed_spin.value = SaveData.shotSpeedUpgradeLevel
	armor_spin.value       = SaveData.armorUpgradeLevel
	regen_spin.value       = SaveData.regenerationUpgradeLevel
	magnet_spin.value      = SaveData.magnetUpgradeLevel
	coin_mult_spin.value   = SaveData.coinMultiplierUpgradeLevel
	dash_spin.value        = SaveData.dashUpgradeLevel
	hypnosis_spin.value    = SaveData.hypnosisPowerUpgradeLevel
	time_slow_spin.value   = SaveData.timeSlowUpgradeLevel
	coins_spin.value       = SaveData.coins

	save_button.pressed.connect(_on_save_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_save_pressed():
	SaveData.healthUpgradeLevel         = int(health_spin.value)
	SaveData.shotPowerUpgradeLevel      = int(shoot_spin.value)
	SaveData.movSpeedUpgradeLevel       = int(move_spin.value)
	SaveData.shotSpeedUpgradeLevel      = int(shoot_speed_spin.value)
	SaveData.armorUpgradeLevel          = int(armor_spin.value)
	SaveData.regenerationUpgradeLevel   = int(regen_spin.value)
	SaveData.magnetUpgradeLevel         = int(magnet_spin.value)
	SaveData.coinMultiplierUpgradeLevel = int(coin_mult_spin.value)
	SaveData.dashUpgradeLevel           = int(dash_spin.value)
	SaveData.hypnosisPowerUpgradeLevel  = int(hypnosis_spin.value)
	SaveData.timeSlowUpgradeLevel       = int(time_slow_spin.value)
	SaveData.coins                      = int(coins_spin.value)

	SaveData.update_skill_data()
	SaveData.save_game()
	print("AdminPanel: saved.")

func _on_close_pressed():
	visible = false
