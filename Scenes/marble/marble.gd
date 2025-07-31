extends RigidBody3D

@export var torque: float = 400
@export var max_angular_vel: float = 100
@onready var visuals : Node3D = $Visuals
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var camera: Camera3D = $CameraAnchor/Camera3D

@onready var rollSFX : AudioStreamPlayer3D = $rollSFX
@onready var groundDetectionAudio : RayCast3D = $groundDetection1/groundDetectionAudio
@onready var groundDetection1 : RayCast3D = $groundDetection1
@onready var groundDetection2 : RayCast3D = $groundDetection1/groundDetection2
@onready var groundDetection3 : RayCast3D = $groundDetection1/groundDetection3

var camera_initial_pos: Vector3

func _ready() -> void:
	camera_initial_pos = camera.position
	camera_anchor.top_level = true
	groundDetection1.top_level = true
	
	rollSFX.volume_linear = 0
	

func _physics_process(delta: float) -> void:
	movement_handler(delta)
	visuals.visuals_handler(delta)
	
	camera_anchor.global_position = global_position + camera_initial_pos
	
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
	
	#audio
	if groundDetectionAudio.is_colliding():
		#print("hi")
		var marbleVOL = max(abs(angular_velocity.x), abs(angular_velocity.y), abs(angular_velocity.z))
		rollSFX.volume_linear = marbleVOL / 100
	else:
		rollSFX.volume_linear = 0
	
	
