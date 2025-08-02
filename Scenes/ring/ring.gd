extends StaticBody3D

@export var apex : Node3D
@export var level_nodepaths : Array[NodePath]
@onready var levels : Array[Level] = []

@onready var x_rot : float = 0.0
@onready var spin_duration : float = 3.0
@onready var spin_timer : float = 0.0

@onready var launched_pos : Vector3 = Vector3.ZERO
@onready var angular_momentum : Vector3 = Vector3.ZERO

@export var ring_spin_curve : Curve
@export var launch_up_curve : Curve
@export var launch_down_curve : Curve

func _ready() -> void:
	Global.ring = self
	var level_nodes : Array = Global.loadNodes(level_nodepaths, self)
	
	levels.resize(level_nodes.size())
	for i in level_nodes.size():
		levels[i] = level_nodes[i]

##no more spinning
#@export var ring_rotation_speed: float = -2.0
func _physics_process(delta: float) -> void:
	
	if spin_timer > 0.0:
		Global.player.camera.camera_shake = max(Global.player.camera.camera_shake, 0.5)
		Global.player.global_rotation += angular_momentum# * delta
		
		spin_timer -= delta
		spin_timer = max(spin_timer, 0.0)
		
		var spin_lerp : float = lerpf(1.0, 0.0, spin_timer / spin_duration)
		
		
		var level_angle_dist : float = deg_to_rad(16.0) #this might become custom per level
		rotation.x = x_rot - lerpf(0.0, level_angle_dist, ring_spin_curve.sample_baked(spin_lerp))
		#rotate_x(ring_rotation_speed / 1000.0)
		
		if spin_timer == 0.0:
			x_rot -= level_angle_dist
			#Global.player.camera.camera_shake = 2.0
			Global.player.visuals.shadow.visible = true
			Global.respawn()
		
		var updown_point : float = 0.5#where in the lerp will we hit the apex
		if spin_lerp < updown_point:
			spin_lerp /= updown_point
			
			Global.player.global_position = launched_pos.lerp(apex.global_position, launch_up_curve.sample_baked(spin_lerp))
		else:
			spin_lerp -= updown_point
			spin_lerp /= updown_point
			Global.player.global_position = levels[Global.level].starter_point.global_position.lerp(apex.global_position, launch_down_curve.sample_baked(spin_lerp))



func spin():
	launched_pos = Global.player.global_position
	Global.player.camera.camera_shake = 1.0
	Global.level += 1
	spin_timer = spin_duration
	angular_momentum = Global.player.angular_velocity
	Global.player.freeze = true
	Global.player.visuals.shadow_alpha = 0.0
	Global.player.visuals.shadow.visible = false

func _input(event):
	if event.is_action_pressed("ui_text_submit"):
		spin()
