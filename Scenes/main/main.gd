extends Node3D

@onready var ambi : AudioStreamPlayer = $"Street Ambi"

@onready var death_area : Area3D = $World/DeathArea
@onready var die_next_physics : bool = false

func _ready() -> void:
	Global.main = self
	get_viewport().connect("size_changed",Callable(self,"_root_viewport_size_changed"))
	
	death_area.body_entered.connect(on_body_entered)
	
	if is_instance_valid(Global.ring.levels[Global.level]):
		if is_instance_valid(Global.ring.levels[Global.level].starter_point):
			Global.player.global_position = Global.ring.levels[Global.level].starter_point.global_position
			



func _physics_process(delta: float):
	if die_next_physics:
		Global.respawn()
		die_next_physics = false

func on_body_entered(body:Node3D):
	if body == Global.player:
		die_next_physics = true


func set_bag_count():
	$Control/BagLabel.text = str(Global.bags_gotten)

func _root_viewport_size_changed():
	pass#$Control/Label.label_settings.font_size = get_viewport().size.y*0.07
