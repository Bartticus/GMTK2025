extends Node3D

@onready var ambi : AudioStreamPlayer = $"Street Ambi"

@onready var death_area : Area3D = $World/DeathArea
@onready var die_next_physics : bool = false
@onready var booster_selected_yes : bool = false
@onready var met_booster : bool = false


@onready var going_down : bool = true
@onready var prompt_alpha : float = 1.0
@onready var tut_progress : int = 0
@export var move_prompt : Control
@export var boost_prompt : Control
@export var boost_bag_prompt : Control

@onready var zoom_path_follow : PathFollow3D = $World/ZoomPath/ZoomFollow

func _ready() -> void:
	Global.main = self
	get_viewport().connect("size_changed",Callable(self,"_root_viewport_size_changed"))
	
	death_area.body_entered.connect(on_body_entered)
	
	if is_instance_valid(Global.ring.levels[Global.level]):
		if is_instance_valid(Global.ring.levels[Global.level].starter_point):
			Global.player.global_position = Global.ring.levels[Global.level].starter_point.global_position
			

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("boost_grant"):
		met_booster = true
	if Global.level < 2:
		if going_down:
			prompt_alpha -= delta * 0.4
			prompt_alpha = max(prompt_alpha, 0.85)
			if prompt_alpha == 0.85:
				going_down = false
		else:
			prompt_alpha += delta * 0.5
			prompt_alpha = min(prompt_alpha, 1.0)
			if prompt_alpha == 1.0:
				going_down = true
		
		match(tut_progress):
			0:
				var player_pos : Vector2 = Vector2(Global.player.global_position.x, Global.player.global_position.z)
				var starter_pos : Vector2 = Vector2(Global.ring.levels[0].starter_point.global_position.x, Global.ring.levels[0].starter_point.global_position.z)
				move_prompt.modulate.a = prompt_alpha
				if (player_pos-starter_pos).length() > 0.5:
					tut_progress += 1
			1:
				if move_prompt.visible:
					move_prompt.modulate.a = lerpf(move_prompt.modulate.a, 0.0, delta*10.0)
					move_prompt.visible = move_prompt.modulate.a > 0.05
			2:
				boost_prompt.modulate.a = prompt_alpha
			3:
				if boost_prompt.visible:
					boost_prompt.modulate.a = lerpf(boost_prompt.modulate.a, 0.0, delta*10.0)
					boost_prompt.visible = boost_prompt.modulate.a > 0.05
				boost_bag_prompt.modulate.a = prompt_alpha
			4:
				if boost_bag_prompt.visible:
					boost_bag_prompt.modulate.a = lerpf(boost_bag_prompt.modulate.a, 0.0, delta*10.0)
					boost_bag_prompt.visible = boost_bag_prompt.modulate.a > 0.05

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
