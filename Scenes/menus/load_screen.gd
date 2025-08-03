extends Control

func _ready() -> void:
	if Global.has_method("_ready") and not Global.already_cached:
		show()
	await Global.cache_finished
	hide()
