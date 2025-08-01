extends RigidBody3D

@export var torque: float = 400
@export var max_angular_vel: float = 100
@export var brake_force: float = 5

@onready var visuals : Node3D = $Visuals
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var camera: Camera3D = $CameraAnchor/Camera3D

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

var camera_initial_pos: Vector3
var initial_friction: float

func _ready() -> void:
	camera_initial_pos = camera.position
	camera_anchor.top_level = true
	groundDetection1.top_level = true
	
	initial_friction = physics_material_override.friction
	
	rollSFX.volume_linear = 0
	windSFX.volume_linear = 0

func _physics_process(delta: float) -> void:
	movement_handler(delta)
	drift_handler(delta)
	visuals.visuals_handler(delta)
	audio_handler()
	
	camera_anchor.global_position = global_position# + camera_initial_pos
	
	groundDetection1.position = self.position

func movement_handler(delta: float) -> void:
	var f_input = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	var h_input = Input.get_action_raw_strength("left") - Input.get_action_raw_strength("right")
	
	var camera_transform = camera.get_camera_transform()#camera_anchor.global_transform
	
	var f_force = f_input * torque * delta * camera_transform.basis.x.normalized()
	var h_force = h_input * torque * delta * camera_transform.basis.z.normalized()
	
	apply_torque(f_force)
	apply_torque(h_force)
	
	angular_velocity.x = clampf(angular_velocity.x, -max_angular_vel, max_angular_vel)
	angular_velocity.y = clampf(angular_velocity.y, -max_angular_vel, max_angular_vel)
	angular_velocity.z = clampf(angular_velocity.z, -max_angular_vel, max_angular_vel)

var new_friction: float = 0
func drift_handler(delta) -> void:
	if not is_on_floor(): return
	
	if Input.is_action_just_pressed("drift"):
		new_friction = 0
	
	if Input.is_action_pressed("drift"):
		linear_velocity = linear_velocity.lerp(Vector3.ZERO, delta * brake_force)
		physics_material_override.friction = 0.1
		
		var max_friction: float = 500
		if new_friction < max_friction:
			new_friction += 20
		
		handle_particles(true)
	
	elif Input.is_action_just_released("drift"):
		physics_material_override.friction = new_friction
		
		var tween: Tween = create_tween()
		tween.tween_property(self, "physics_material_override:friction", initial_friction, 2)
		
		handle_particles(false)

func handle_particles(is_drifting: bool) -> void:
	spark_particles1.emitting = is_drifting
	spark_particles2.emitting = is_drifting
	
	smoke_particles1.emitting = not is_drifting
	smoke_particles2.emitting = not is_drifting
	
	
	var state = PhysicsServer3D.body_get_direct_state(get_rid())
	if state:
		for i in state.get_contact_count():
			contact_pos = state.get_contact_local_position(i)
	print(contact_pos)
	
	particles.global_position = contact_pos
	
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
	

var contact_pos: Vector3
#func _on_body_entered(body: Node) -> void:
	#var state = PhysicsServer3D.body_get_direct_state(get_rid())
	#if state:
		#for i in state.get_contact_count():
			#contact_pos = state.get_contact_local_position(i)
