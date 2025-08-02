extends StaticBody3D

@export var levels : Array[NodePath]

@onready var spin_duration : float = 5.0

@onready var spin_timer : float = 0.0

##no more spinning
#@export var ring_rotation_speed: float = -2.0
#func _physics_process(delta: float) -> void:
	#rotate_x(ring_rotation_speed / 1000.0)


func spin():
	spin_timer

func _input(event):
	if event.is_action_pressed("ui_accept"):
		spin()
