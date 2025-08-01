extends RigidBody3D

@export var torque: float = 400
@export var max_angular_vel: float = 100
@export var brake_force: float = 5

@onready var visuals : Node3D = $Visuals
@onready var camera_anchor: Node3D = $CameraAnchor
#@onready var camera: Camera3D = $CameraAnchor/Camera3D
@onready var camera: Camera3D = $SpringArmPivot/ThirdPersonCamera
@onready var spring_arm_pivot: Node3D = $SpringArmPivot

@onready var drift_fx : Node3D = $DriftFX
@onready var particles: Node3D = $Particles
@onready var spark_particles1: GPUParticles3D = $Particles/DriftSparkParticles1
@onready var spark_particles2: GPUParticles3D = $Particles/DriftSparkParticles1/DriftSparkParticles2
@onready var smoke_particles1: GPUParticles3D = $Particles/DriftSmokeParticles1
@onready var smoke_particles2: GPUParticles3D = $Particles/DriftSmokeParticles1/DriftSmokeParticles2

@onready var rollSFX : AudioStreamPlayer3D = $rollSFX
@onready var groundDetectionAudio : RayCast3D = $groundDetection1/groundDetectionAudio
@onready var groundDetection1 : RayCast3D = $groundDetection1
@onready var groundDetection2 : RayCast3D = $groundDetection1/groundDetection2
@onready var groundDetection3 : RayCast3D = $groundDetection1/groundDetection3

@onready var windSFX : AudioStreamPlayer3D = $windSFX

var initial_friction: float
var input_vector: Vector3

func _ready() -> void:
	camera_anchor.top_level = true
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
	
	camera_anchor.global_position = global_position
	drift_fx.global_position = global_position
	
	groundDetection1.position = self.position
	spring_arm_pivot.position = self.position

func movement_handler(delta: float) -> void:
	var f_input = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	var h_input = Input.get_action_raw_strength("left") - Input.get_action_raw_strength("right")
	input_vector = Vector3(h_input, 0, -f_input) * 0.25
	
	var camera_transform = camera.get_camera_transform()
	
	var f_force = f_input * torque * delta * camera_transform.basis.x.normalized()
	var h_force = h_input * torque * delta * camera_transform.basis.z.normalized()
	
	apply_torque(f_force)
	apply_torque(h_force)
	
	angular_velocity.x = clampf(angular_velocity.x, -max_angular_vel, max_angular_vel)
	angular_velocity.y = clampf(angular_velocity.y, -max_angular_vel, max_angular_vel)
	angular_velocity.z = clampf(angular_velocity.z, -max_angular_vel, max_angular_vel)
	
	
	if abs(f_input) > 0.15 or abs(h_input) > 0.15:
		drift_fx.current_move_rot = atan2(h_force.z, -f_force.x)#Vector2(f_force.x, h_force.z)
	else:
		drift_fx.current_move_rot = -atan2(linear_velocity.x, -linear_velocity.z)

var new_friction: float = 0

func drift_handler(delta) -> void:
	if not is_on_floor():
		particle_handler(false)
		return
	
	if Input.is_action_just_pressed("drift"):
		new_friction = 0
	
	
	
	if Input.is_action_pressed("drift"):
		linear_velocity = linear_velocity.lerp(Vector3.ZERO, delta * brake_force)
		physics_material_override.friction = 0.1
		
		var max_friction: float = 500
		if new_friction < max_friction:
			new_friction += 20
		
		drift_fx.currently_drifting = true
		particle_handler(true)
	
	elif Input.is_action_just_released("drift"):
		physics_material_override.friction = new_friction
		
		var tween: Tween = create_tween()
		tween.tween_property(self, "physics_material_override:friction", initial_friction, 2)
		
		drift_fx.currently_drifting = false
		particle_handler(false)

var rot_speed: float
var contact_pos: Vector3
func particle_handler(is_drifting: bool) -> void:
	rot_speed = angular_velocity.length()
	var draw_size: Vector2 = Vector2(rot_speed, rot_speed) / 100
	spark_particles1.draw_pass_1.size = draw_size
	
	var hue: float = 0
	if abs(rot_speed) < 50:
		hue = .6
	elif abs(rot_speed) < 100:
		hue = .08
	var new_color = Color.from_hsv(hue, 1 , 100)
	spark_particles1.draw_pass_1.material.albedo_color = new_color
	
	spark_particles1.emitting = is_drifting
	spark_particles2.emitting = is_drifting
	
	if not is_drifting:
		smoke_particles1.restart()
		smoke_particles1.global_position = particles.global_position + input_vector
	
	smoke_particles1.emitting = !is_drifting
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
	
	#if groundDetectionAudio.is_colliding():
	if is_on_floor():
		rollSFX.volume_linear = marbleVOL / 100
	else:
		rollSFX.volume_linear = 0
	
	windSFX.volume_linear = marbleVOL / 100
	
