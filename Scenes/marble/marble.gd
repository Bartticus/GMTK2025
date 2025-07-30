extends RigidBody3D

@export var torque: float = 400
@export var max_angular_vel: float = 100
@onready var visuals : Node3D = $Visuals
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var camera: Camera3D = $CameraAnchor/Camera3D
var camera_initial_pos: Vector3

func _ready() -> void:
	camera_anchor.top_level = true
	camera_initial_pos = camera_anchor.position
	

func _physics_process(delta: float) -> void:
	movement_handler(delta)
	visuals.visuals_handler(delta)
	
	camera_anchor.global_position = global_position + camera_initial_pos
	

func movement_handler(delta: float) -> void:
	var f_input = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	var h_input = Input.get_action_raw_strength("left") - Input.get_action_raw_strength("right")
	
	var camera_transform = camera_anchor.global_transform#get_camera_transform()
	
	var f_force = f_input * torque * delta * camera_transform.basis.x.normalized()
	var h_force = h_input * torque * delta * camera_transform.basis.z.normalized()
	
	apply_torque(f_force)
	apply_torque(h_force)
	
	angular_velocity.x = clampf(angular_velocity.x, -max_angular_vel, max_angular_vel)
	angular_velocity.y = clampf(angular_velocity.y, -max_angular_vel, max_angular_vel)
	angular_velocity.z = clampf(angular_velocity.z, -max_angular_vel, max_angular_vel)
	
	print(angular_velocity)
