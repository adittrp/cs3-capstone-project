extends Button

signal skill_selected(data)

var skill_data: Dictionary

func set_data(data: Dictionary):
	skill_data = data
	$Label.text = data.name
	$Icon.texture = data.icon

func _pressed():
	emit_signal("skill_selected", skill_data)
