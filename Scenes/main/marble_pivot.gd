extends Node3D

func _physics_process(delta: float) -> void:
	rotation.x = Global.ring.rotation.x
