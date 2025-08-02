class_name Marble
extends RigidBody3D

@export_range(0.0, 600.0, 10.0) var torque: float = 200
@export var max_angular_vel: float = 100
@export var brake_force: float = 5
@export_range(0.0, 1000.0, 10.0) var linear_force : float = 500.0
@export var drifting_velocity_boost: float = 2.0

@onready var visuals : Node3D = $Visuals
@onready var camera: Camera3D = $SpringArmPivotY/PivotX/ThirdPersonCamera
@onready var spring_arm_pivot: Node3D = $SpringArmPivotY
@onready var coyote_timer: Timer = $CoyoteTimer

@onready var drifting_last_keyboard_f_force : Vector3 = Vector3.ZERO
@onready var drifting_last_keyboard_h_force : Vector3 = Vector3.ZERO
@onready var drift_fx : Node3D = $DriftFX
@onready var particles: Node3D = $Particles
@onready var spark_particles1: GPUParticles3D = $Particles/DriftSparkParticles1
@onready var spark_particles2: GPUParticles3D = $Particles/DriftSparkParticles1/DriftSparkParticles2
@onready var smoke_particles1: GPUParticles3D = $Particles/DriftSmokeParticles1
@onready var smoke_particles2: GPUParticles3D = $Particles/DriftSmokeParticles1/DriftSmokeParticles2

@onready var groundDetectionAudio : RayCast3D = $groundDetection1/groundDetectionAudio
@onready var groundDetection1 : RayCast3D = $groundDetection1
@onready var groundDetection2 : RayCast3D = $groundDetection1/groundDetection2
@onready var groundDetection3 : RayCast3D = $groundDetection1/groundDetection3

#audio
@onready var rollSFX : AudioStreamPlayer3D = $Audio/rollSFX
@onready var windSFX : AudioStreamPlayer = $Audio/windSFX

var initial_friction: float
var input_vector: Vector3

func _ready() -> void:
	Global.player = self
	groundDetection1.top_level = true
	drift_fx.top_level = true
	
	initial_friction = physics_material_override.friction
	
	rollSFX.volume_linear = 0
	windSFX.volume_linear = 0

func _physics_process(delta: float) -> void:
	movement_handler(delta)
	drift_handler(delta)
	visuals.visuals_handler(delta)
	audio_handler()
	
	drift_fx.global_position = global_position
	
	groundDetection1.position = self.position
	spring_arm_pivot.position = self.position

func movement_handler(delta: float) -> void:
	var f_input = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	var h_input = Input.get_action_raw_strength("left") - Input.get_action_raw_strength("right")
	input_vector = Vector3(h_input, 0, -f_input) * 0.25
	
	if !Input.is_action_pressed("drift") and linear_velocity.length() > 0.0:#tone down the angular torque we add the faster we're going, to near 0 if we're spinny real fast
		var angular_addition_modifier : float = angular_velocity.length() / 20.0
		angular_addition_modifier = min(angular_addition_modifier, 1.0)#now a lerp value between 0-1 where 1 is maximum torque braking
		
		var fully_slowed_input : Vector2 = Vector2(lerpf(f_input, 0.1, angular_addition_modifier), lerpf(h_input, 0.1, angular_addition_modifier))
		
		var dir_diff_lerp : float = input_vector.normalized().dot(linear_velocity.normalized())#-1 when wasd matches current velocity direction, 1 when opposite
		dir_diff_lerp += 1
		dir_diff_lerp *= 0.5#now a 0 to 1 range instead of -1 to 1
		f_input = lerpf(fully_slowed_input.x, f_input, dir_diff_lerp)
		h_input = lerpf(fully_slowed_input.y, h_input, dir_diff_lerp)
	
	var camera_transform = spring_arm_pivot.global_transform
	
	var f_force = f_input * torque * delta * camera_transform.basis.x.normalized()
	var h_force = h_input * torque * delta * camera_transform.basis.z.normalized()
	
	if drift_fx.currently_drifting:
		f_force *= 1.5
		h_force *= 1.5
	
	apply_torque(f_force)
	apply_torque(h_force)
	
	angular_velocity.x = clampf(angular_velocity.x, -max_angular_vel, max_angular_vel)
	angular_velocity.y = clampf(angular_velocity.y, -max_angular_vel, max_angular_vel)
	angular_velocity.z = clampf(angular_velocity.z, -max_angular_vel, max_angular_vel)
	
	if abs(f_input) > 0.1 or abs(h_input) > 0.1:
		var look_vec : Vector2 = Vector2(-input_vector.z, input_vector.x)
		look_vec = look_vec.rotated(-camera.global_rotation.y)
		drift_fx.current_move_rot = atan2(look_vec.y, -look_vec.x)
	else:
		drift_fx.current_move_rot = atan2(linear_velocity.z, -linear_velocity.x) + PI/2
	
	f_force = f_input * linear_force * delta * camera_transform.basis.z.normalized()
	h_force = h_input * linear_force * delta * camera_transform.basis.x.normalized()
	
	if not is_on_floor() or true:
		apply_central_force(f_force)
		apply_central_force(-h_force)
	
	if abs(f_input) > 0.1 or abs(h_input) > 0.1:
		var look_vec : Vector2 = Vector2(-input_vector.z, input_vector.x)
		look_vec = look_vec.rotated(-camera.global_rotation.y)
		drift_fx.current_move_rot = atan2(look_vec.y, -look_vec.x)
		drifting_last_keyboard_f_force = f_force
		drifting_last_keyboard_h_force = h_force
	else:
		drift_fx.current_move_rot = atan2(linear_velocity.z, -linear_velocity.x) + PI/2
	
	#linear_velocity.x = clampf(linear_velocity.x, -max_velocity, max_velocity)
	#linear_velocity.z = clampf(linear_velocity.z, -max_velocity, max_velocity)
	
	if is_on_floor() and Input.is_action_just_released("drift"):
		var boost : float = drift_fx.drifting_timer / 0.8
		boost = min(boost, 1.0)
		boost *= drifting_velocity_boost
		apply_central_impulse(drifting_last_keyboard_f_force * boost * rot_speed_factor)
		apply_central_impulse(-drifting_last_keyboard_h_force * boost * rot_speed_factor)
		drifting_last_keyboard_f_force = Vector3.ZERO
		drifting_last_keyboard_h_force = Vector3.ZERO

var new_friction: float = 0

func drift_handler(delta) -> void:
	if not is_on_floor():
		if coyote_timer.is_stopped():
			drift_fx.currently_drifting = false
			particle_handler(false)
			return
	else:
		coyote_timer.start()
	
	if Input.is_action_just_pressed("drift"):
		new_friction = 0
	
	if Input.is_action_pressed("drift") and !coyote_timer.is_stopped():
		linear_velocity = linear_velocity.lerp(Vector3.ZERO, brake_force * delta)
		physics_material_override.friction = 0.1
		
		var max_friction: float = 1000
		if new_friction < max_friction:
			new_friction += 20
		
		drift_fx.currently_drifting = true
		particle_handler(true)
		
		var shake_amount : float = angular_velocity.length() / 20.0
		shake_amount = min(shake_amount, 1.0)#now a lerp value between 0-1 where 1 is maximum torque braking
		camera.camera_shake = lerpf(0.0, 0.7, shake_amount)
	
	elif Input.is_action_just_released("drift"):
		physics_material_override.friction = new_friction
		
		var tween: Tween = create_tween()
		tween.tween_property(self, "physics_material_override:friction", initial_friction, 2)
		
		drift_fx.currently_drifting = false
		particle_handler(false, true)

var contact_pos: Vector3
var rot_speed_factor: float

func particle_handler(is_drifting: bool, just_released: bool = false) -> void:
	rot_speed_factor = angular_velocity.length() / max_angular_vel
	var draw_size: Vector2 = Vector2(rot_speed_factor, rot_speed_factor)
	spark_particles1.draw_pass_1.size = draw_size
	
	var hue: float
	if abs(rot_speed_factor) < .4: #slow
		hue = .6 #blue
	elif abs(rot_speed_factor) < .7: #medium
		hue = .83 #red
	else: #fast
		hue = 0 #purple
	var new_color = Color.from_hsv(hue, 1 , 100)
	spark_particles1.draw_pass_1.material.albedo_color = new_color
	
	spark_particles1.emitting = is_drifting
	spark_particles2.emitting = is_drifting
	
	if just_released:
		smoke_particles1.restart()
		smoke_particles1.global_position = particles.global_position + input_vector
		smoke_particles1.emitting = true
	else:
		smoke_particles1.emitting = false
	smoke_particles2.emitting = is_drifting
	
	var state = PhysicsServer3D.body_get_direct_state(get_rid())
	if state:
		for i in state.get_contact_count():
			contact_pos = state.get_contact_local_position(i)
	
	particles.global_position = contact_pos + input_vector
	
func is_on_floor() -> bool:
	for body in get_colliding_bodies():
		if body.collision_layer == 1:
			return true
	return false

func audio_handler() -> void:
	#audio
	var marbleVOL = max(abs(angular_velocity.x), abs(angular_velocity.y), abs(angular_velocity.z))
	var windVOL = linear_velocity.length()
	
	#if groundDetectionAudio.is_colliding():
	if is_on_floor():
		rollSFX.volume_linear = marbleVOL / 100
	else:
		rollSFX.volume_linear = 0
	
	windSFX.volume_linear = windVOL / 50
