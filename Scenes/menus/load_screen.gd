extends Control

func _ready() -> void:
	show()
	await Global.cache_finished
	hide()
