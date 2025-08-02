extends HSlider

func _ready() -> void:
	value = Global.mouse_sensitivity * 100
	value_changed.connect(_on_value_changed)

func _on_value_changed(_value: float) -> void:
	Global.mouse_sensitivity = value / 100
