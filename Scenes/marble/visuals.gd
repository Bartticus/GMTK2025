extends Node3D

@export_range(0.0, 3.0, 0.1) var scale_distortion_scale : float = 1.0
@export var scale_distortion_start_velocity : float = 3.0
@export var squash_distortion_max_velocity : float = 20.0#we won't squash any more even if we're going faster than this

@export var squash_z_curve : Curve
@export var squash_x_curve : Curve

@export var marble : RigidBody3D
@onready var marble_mesh : MeshInstance3D = $MarbleMesh
@onready var smoothed_velocity : Vector3 = Vector3.ZERO


@export var squash_length : float = 0.3
@onready var squash_timer : float = 0.0
@onready var squash_intensity : float = 0.0
@onready var velocity_last_frame : Vector3 = Vector3.ZERO

func _ready() -> void:
	top_level = true



func impact(intensity : float = 0.0)->void:#intensity is 0-1
	squash_timer = squash_length
	squash_intensity = lerpf(0.0, 5.0, intensity)

func visuals_handler(delta: float) -> void:
	set_identity()
	global_position = marble.global_position
	
	smoothed_velocity = smoothed_velocity.lerp(marble.linear_velocity, delta * 7.0)
	look_at(global_position+smoothed_velocity)
	marble_mesh.global_rotation = marble.global_rotation
	
	var current_speed = smoothed_velocity.length() - scale_distortion_start_velocity
	current_speed = max(current_speed, 0.0)
	var speed_factor : float = current_speed / 14.0
	speed_factor = min(speed_factor, 1.0)
	
	var speed_change : float = velocity_last_frame.length() - marble.linear_velocity.length()
	var impact_scale : float = marble.linear_velocity.angle_to(velocity_last_frame) - 1.0
	if impact_scale > 0.0:
		impact_scale /= squash_distortion_max_velocity
		impact_scale = min(impact_scale, 1.0)
		impact(impact_scale)
	else:
		impact_scale = speed_change - 5.0
		if impact_scale > 0.0:
			impact_scale /= squash_distortion_max_velocity
			impact_scale = min(impact_scale, 1.0)
			impact(impact_scale)
	
	
	var new_scale : Vector3 = Vector3.ONE
	new_scale.z = lerpf(1.0, 1.0 + (0.2 * scale_distortion_scale), speed_factor)
	new_scale.x = lerpf(1.0, 1.0 - (0.1 * scale_distortion_scale), speed_factor)
	
	if squash_timer > 0.0:
		squash_timer -= delta
		squash_timer = max(squash_timer, 0.0)
		var squash_lerp : float = lerpf(1.0, 0.0, squash_timer / squash_length)
		new_scale.z += squash_z_curve.sample_baked(squash_lerp) * squash_intensity
		new_scale.x += squash_x_curve.sample_baked(squash_lerp) * squash_intensity
	
	scale_object_local(new_scale)
	
	velocity_last_frame = marble.linear_velocity
