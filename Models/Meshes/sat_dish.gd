@tool

extends Node3D



@export var satdish : MeshInstance3D
@onready var dish_body : StaticBody3D = $"satdish2/@StaticBody3D@43267"
@export var dish_collidor : CollisionShape3D

@export var dish_rotation : Vector3 = Vector3.ZERO:
	set(value):
		satdish.global_rotation = value
		dish_collidor.global_rotation = value
		dish_rotation = value

func _ready() -> void:
	satdish.position.y = 1.705
	dish_body.position.y = 1.705
