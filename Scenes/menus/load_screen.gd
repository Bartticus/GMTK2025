extends Control

func _ready() -> void:
	await Global.cache_finished
	hide()
