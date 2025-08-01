extends Node3D

@export var hover_curve : Curve
@onready var bagmesh : MeshInstance3D = $BagMesh


@onready var going_down : bool = false
@onready var height_lerp : float = 0.0


func _process(delta: float) -> void:
	bagmesh.rotate_y(delta)
	
	if going_down:
		height_lerp -= delta
		height_lerp = max(height_lerp, 0.0)
		if height_lerp == 0.0:
			going_down = false
	else:
		height_lerp += delta
		height_lerp = min(height_lerp, 1.0)
		if height_lerp == 1.0:
			going_down = true
	
	bagmesh.position.y = lerpf(0.0, 0.5, hover_curve.sample_baked(height_lerp))
