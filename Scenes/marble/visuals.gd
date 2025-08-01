extends Node3D

@export_range(0.0, 3.0, 0.1) var scale_distortion_scale : float = 1.0
@export_range(0.0, 20.0, 0.3) var impulse_minimum_impact : float = 7.0
@export var scale_distortion_start_velocity : float = 3.0
@export var squash_distortion_max_velocity : float = 20.0#we won't squash any more even if we're going faster than this

@export var squash_z_curve : Curve
@export var squash_x_curve : Curve

@export var marble : RigidBody3D
@onready var marble_mesh : MeshInstance3D = $MarbleMesh
@onready var impact_fx : Node3D = $ImpactFX
@onready var smoothed_velocity : Vector3 = Vector3.ZERO
@onready var contact_normal : Vector3 = Vector3.ZERO

@export var squash_length : float = 0.3
@onready var squash_timer : float = 0.0
@onready var squash_intensity : float = 0.0

func _ready() -> void:
	top_level = true
	impact_fx.top_level = true
	impact_fx.visible = false

func impact(intensity : float = 0.0, contact_position : Vector3 = Vector3.ZERO, normal : Vector3 = Vector3.ZERO)->void:#intensity is 0-1
	squash_timer = squash_length
	squash_intensity = lerpf(0.0, 0.5, intensity)
	
	#marble.camera.camera_shake = 1.0
	
	var fx : Node3D = impact_fx.duplicate()
	add_child(fx)
	fx.visible = true
	fx.global_position = contact_position
	if not Vector3.UP.cross(-normal.normalized()).is_zero_approx():
		fx.look_at(contact_position + normal)
	fx.sprite.rotate_z(randf())

func visuals_handler(delta: float) -> void:
	set_identity()
	global_position = marble.global_position
	
	smoothed_velocity = smoothed_velocity.lerp(marble.linear_velocity, delta * 7.0)
	if not Vector3.UP.cross(-smoothed_velocity.normalized()).is_zero_approx() \
	and not smoothed_velocity.is_zero_approx():
		look_at(global_position + smoothed_velocity)
	
	marble_mesh.global_rotation = marble.global_rotation
	
	var current_speed = smoothed_velocity.length() - scale_distortion_start_velocity
	current_speed = max(current_speed, 0.0)
	var speed_factor : float = current_speed / 14.0
	speed_factor = min(speed_factor, 1.0)
	
	
	var state = PhysicsServer3D.body_get_direct_state(marble.get_rid())
	var contact_count : int = state.get_contact_count()
	var biggest_impulse : float = 0.0
	var contact_position : Vector3 = Vector3.ZERO
	
	for i in contact_count:
		if biggest_impulse < state.get_contact_impulse(i).length():
			contact_position = state.get_contact_local_position(i)
			contact_normal = state.get_contact_local_normal(i)
		biggest_impulse = max(biggest_impulse, state.get_contact_impulse(i).length())
	
	
	biggest_impulse -= impulse_minimum_impact
	if biggest_impulse > 0.0:
		var impact_scale = biggest_impulse / squash_distortion_max_velocity
		impact_scale = min(impact_scale, 1.0)
		impact(impact_scale, contact_position, contact_normal)
	#else:
		#contact_normal = Vector3.ZERO
	
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
