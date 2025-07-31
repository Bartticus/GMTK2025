extends StaticBody3D

@export var ring_rotation_speed: float = -2.0

func _physics_process(delta: float) -> void:
	rotate_x(ring_rotation_speed / 1000.0)
