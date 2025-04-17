extends Button

signal ability_selected(data)

var ability_data: Dictionary

func set_data(data: Dictionary):
	ability_data = data
	$Label.text = data.name
	$Icon.texture = data.icon

func _pressed():
	emit_signal("ability_selected", ability_data)
