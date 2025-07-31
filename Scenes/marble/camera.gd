extends Camera3D
@export var marble : RigidBody3D
@export var pivot : Node3D

@onready var camera_shake : float = 0.0
@export var shake_noise : Noise
@onready var frequency : float = 0.0
@onready var pivot_rotation : float = 0.0


func _process(delta: float) -> void:
	if camera_shake > 0.0:
		var shake_freq = frequency*5.0
		var shake_amount = 0.13 * camera_shake
		var sampler = shake_noise.get_noise_2d(shake_freq, 0.0)
		h_offset = lerp(0.0, shake_amount, sampler)
		sampler = shake_noise.get_noise_2d(0.0, shake_freq)
		v_offset = lerp(0.0, shake_amount, sampler)
		
		frequency += delta
	
	camera_shake = lerpf(camera_shake, 0.0, delta * 7.0)
	
	
	var fov_target : float = lerpf(80.0, 81.0, marble.linear_velocity.length())
	fov_target = min(fov_target, 110.0)
	fov = lerpf(fov, fov_target, delta * 2.0)
	
	var normal : Vector3 = Vector3.ZERO
	
	if marble.groundDetection1.is_colliding():
		normal = marble.groundDetection1.get_collision_normal()
	elif marble.groundDetection2.is_colliding():
		normal = marble.groundDetection2.get_collision_normal()
	elif marble.groundDetection3.is_colliding():
		normal = marble.groundDetection3.get_collision_normal()
	
	if normal != Vector3.ZERO:
		#marble.visuals.contact_normal
		var pivot_tilt : float = 0.3
		var target_rot : float = lerpf(-pivot_tilt, pivot_tilt, normal.z)
		if target_rot < 0.0: target_rot *= 1.9#more rotation for near slope so we don't clip
		pivot_rotation = lerpf(pivot_rotation, target_rot, delta*3.0)
		#print(target_rot)
	else:
		pivot_rotation = lerpf(pivot_rotation, 0.0, delta)
	
	pivot.global_transform.basis = Basis.IDENTITY
	pivot.rotate_x(pivot_rotation)
	
	
	
