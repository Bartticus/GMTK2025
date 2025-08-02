extends Node3D

@export var hover_curve : Curve
@export var white_mat : StandardMaterial3D
@onready var bagmesh : MeshInstance3D = $BagMesh
@onready var collected : bool = false

@export var squash_length : float = 0.2
@onready var squash_timer : float = 0.0
@onready var squash_intensity : float = 0.8

@onready var going_down : bool = false
@onready var height_lerp : float = 0.0

signal bag_collected

func _ready() -> void:
	$Area3D.body_entered.connect(on_body_entered)

func _process(delta: float) -> void:
	if collected:
		squash_timer += delta
		squash_timer = max(squash_timer, 0.0)
		var squash_lerp : float = lerpf(0.0, 1.0, squash_timer / squash_length)
		var new_scale = Vector3.ONE * 1.7
		new_scale.y += Global.player.visuals.squash_z_curve.sample_baked(squash_lerp) * squash_intensity
		new_scale.x += Global.player.visuals.squash_x_curve.sample_baked(squash_lerp) * squash_intensity
		new_scale.z += Global.player.visuals.squash_x_curve.sample_baked(squash_lerp) * squash_intensity
		
		bagmesh.scale = new_scale
		if squash_timer > squash_length:
			queue_free()
	
	else:
		bagmesh.rotate_y(delta)
		
		if going_down:
			height_lerp -= delta
			height_lerp = max(height_lerp, 0.0)
			if height_lerp == 0.0:
				going_down = false
		else:
			height_lerp += delta
			height_lerp = min(height_lerp, 1.0)
			if height_lerp == 1.0:
				going_down = true
		
		bagmesh.position.y = lerpf(0.0, 0.5, hover_curve.sample_baked(height_lerp))
	
	

func just_collected():
	collected = true
	bag_collected.emit()
	Global.bags_gotten += 1
	bagmesh.set_surface_override_material(0, white_mat)
	bagmesh.set_surface_override_material(1, white_mat)
	
	Global.emit_signal("bag_collected_sfx")


func on_body_entered(body : Node3D):
	if body == Global.player:#should always be true given physics mask
		just_collected()
