extends Level

@export var recuiter_npc : Node3D
@export var first_bag : Node3D

@onready var bag_mat_reset_timer : float = 0.0
@onready var bag_yellow : StandardMaterial3D = load("res://Scenes/bag/BagYellow.tres")
@onready var bag_black : StandardMaterial3D = load("res://Scenes/bag/BagBlack.tres")


func _ready() -> void:
	first_bag.bag_collected.connect(on_bag_collected)
	#recuiter_npc.visible = false #this needs to happen when shipping game

func _process(delta: float) -> void:
	if bag_mat_reset_timer > 0.0:
		bag_mat_reset_timer -= delta
		if bag_mat_reset_timer <= 0.0:
			first_bag.bagmesh.set_surface_override_material(0, bag_yellow)
			first_bag.bagmesh.set_surface_override_material(1, bag_black)
	

func on_bag_collected():
	Global.main.tut_progress = 4
	recuiter_npc.visible = true
