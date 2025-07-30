extends Node3D

@export var scale_distortion_scale : float = 1.3

@export var marble : RigidBody3D
@onready var marble_mesh : MeshInstance3D = $MarbleMesh
@onready var smoothed_velocity : Vector3 = Vector3.ZERO
@onready var scale_distortion : Vector3 = Vector3.ZERO

func _ready() -> void:
	top_level = true





func visuals_handler(delta: float) -> void:
	set_identity()
	global_position = marble.global_position
	
	smoothed_velocity = smoothed_velocity.lerp(marble.linear_velocity, delta * 10.0)
	look_at(global_position+smoothed_velocity)
	
	var speed_factor : float = smoothed_velocity.length() / 7.0
	speed_factor = min(speed_factor, scale_distortion_scale)
	
	var new_scale : Vector3 = Vector3.ONE
	new_scale.z = lerpf(1.0, scale_distortion_scale, speed_factor)
	#scale = scale_distortion
	scale_object_local(new_scale)
	
	marble_mesh.global_rotation = marble.global_rotation
	
