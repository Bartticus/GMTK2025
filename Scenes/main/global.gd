extends Node

@onready var level : int = 0
@onready var player : RigidBody3D
@onready var main : Node3D
@onready var ring : StaticBody3D

const balloon = preload("res://Levels/Dialogue/balloon.tscn")

@onready var bags_gotten : int = 0:
	set(value):
		bags_gotten = value
		Global.main.set_bag_count()
	
#audio
signal bag_collected_sfx
signal dialogue_line_advance

var mouse_sensitivity: float = 0.005


func respawn():#should be called from physics_process
	if level < ring.levels.size():
		
		if is_instance_valid(ring.levels[level]):
			if is_instance_valid(ring.levels[level].starter_point):
				player.visuals.ignore_next_velocity_squash = true
				player.freeze = true
				player.global_position = ring.levels[level].starter_point.global_position
				player.freeze = false
				var spike_force : float = 30.0
				player.apply_central_impulse(Vector3(0.0, -spike_force, 0.0))
				
#
#func _ready() -> void:
	#particle_cache() #REENABLE FOR EXPORT

signal cache_finished

func particle_cache() -> void:
	while not is_instance_valid(player):
		await get_tree().process_frame
		if is_instance_valid(player):
			break
	
	player.particles.process_mode = Node.PROCESS_MODE_ALWAYS
	player.particles.global_position = player.camera.global_position + Vector3.FORWARD
	get_tree().set_deferred("paused", true)
	for child in player.particles.get_children():
		if child is GPUParticles3D:
			child.emitting = true
			await get_tree().create_timer(0.5).timeout
			child.emitting = false
	get_tree().set_deferred("paused", false)
	player.particles.process_mode = Node.PROCESS_MODE_INHERIT
	
	cache_finished.emit()

func dialogue_line_advanced(only_voice : bool = false):
	dialogue_line_advance.emit(only_voice)

func loadNodes(nodePaths: Array, caller) -> Array:
	var nodes := []
	var node
	for nodePath in nodePaths:
		node = caller.get_node(nodePath)
		if node != null or true:
			nodes.append(node)
	return nodes
