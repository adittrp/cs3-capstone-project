extends Label

func _process(_delta: float) -> void:
	self.text = str(SaveData.coins)
