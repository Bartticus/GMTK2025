extends RigidBody3D

@export var move_speed: float = 400
@export var max_velocity: float = 10
@onready var camera: Camera3D = $Camera3D
var camera_initial_pos: Vector3

func _ready() -> void:
	camera.top_level = true
	camera_initial_pos = camera.position
	

func _physics_process(delta: float) -> void:
	movement_handler(delta)
	
	camera.global_position = global_position + camera_initial_pos
	

func movement_handler(delta: float) -> void:
	var f_input = Input.get_action_raw_strength("backward") - Input.get_action_raw_strength("forward")
	var h_input = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	
	var camera_transform = camera.get_camera_transform()
	
	var f_force = f_input * move_speed * delta * camera_transform.basis.z.normalized()
	var h_force = h_input * move_speed * delta * camera_transform.basis.x.normalized()
	
	apply_central_force(f_force)
	apply_central_force(h_force)
	
	linear_velocity.x = clampf(linear_velocity.x, -max_velocity, max_velocity)
	linear_velocity.z = clampf(linear_velocity.z, -max_velocity, max_velocity)
