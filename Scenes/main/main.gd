extends Node3D

@onready var bags_gotten : int = 0

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
