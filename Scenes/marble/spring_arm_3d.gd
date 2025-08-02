extends Node3D

@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = PI/4

@onready var pivot_x : Node3D = $PivotX
@onready var spring_arm: SpringArm3D = $PivotX/SpringArm3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * Global.mouse_sensitivity
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		pivot_x.rotation.x -= event.relative.y * Global.mouse_sensitivity
		pivot_x.rotation.x = clamp(pivot_x.rotation.x, min_vertical_angle, max_vertical_angle)
	
	if event.is_action_pressed("wheel_up") and spring_arm.spring_length >= 5:
		spring_arm.spring_length -= 1
	if event.is_action_pressed("wheel_down") and spring_arm.spring_length <= 15:
		spring_arm.spring_length += 1
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and not Global.player.talking:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func on_dialogue_ended(resource: DialogueResource):
	Global.player.talking = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.ring.spin()
