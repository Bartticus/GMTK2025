extends Node

@onready var player : RigidBody3D
@onready var main : Node3D
@onready var bags_gotten : int = 0:
	set(value):
		bags_gotten = value
		Global.main.set_bag_count()
		
