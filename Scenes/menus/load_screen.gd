extends Control

func _ready() -> void:
	if Global.has_method("_ready"):
		show()
	await Global.cache_finished
	hide()
