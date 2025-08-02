extends Node

@onready var level : int = 0
@onready var player : RigidBody3D
@onready var main : Node3D
@onready var ring : StaticBody3D
@onready var bags_gotten : int = 0:
	set(value):
		bags_gotten = value
		Global.main.set_bag_count()
	
#audio
signal bag_collected_sfx()

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
				
				




func loadNodes(nodePaths: Array, caller) -> Array:
	var nodes := []
	var node
	for nodePath in nodePaths:
		node = caller.get_node(nodePath)
		if node != null or true:
			nodes.append(node)
	return nodes
