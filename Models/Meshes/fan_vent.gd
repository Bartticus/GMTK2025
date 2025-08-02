extends Node3D

@onready var fan1 : MeshInstance3D = $fans/fan1
@onready var fan2 : MeshInstance3D = $fans/fan2

func _process(delta: float) -> void:
	fan1.rotate_y(delta)
	fan2.rotate_y(delta)
