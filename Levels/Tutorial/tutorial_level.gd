extends Level

@export var recuiter_npc : Node3D
@export var first_bag : Node3D
@export var move_prompt : Control
@export var boost_prompt : Control

@onready var going_down : bool = true
@onready var prompt_alpha : float = 1.0

@onready var bag_mat_reset_timer : float = 0.0
@onready var bag_yellow : StandardMaterial3D = load("res://Scenes/bag/BagYellow.tres")
@onready var bag_black : StandardMaterial3D = load("res://Scenes/bag/BagBlack.tres")

@onready var tut_progress : int = 0

func _ready() -> void:
	first_bag.bag_collected.connect(on_bag_collected)
	#recuiter_npc.visible = false #this needs to happen when shipping game

func _process(delta: float) -> void:
	if bag_mat_reset_timer > 0.0:
		bag_mat_reset_timer -= delta
		if bag_mat_reset_timer <= 0.0:
			first_bag.bagmesh.set_surface_override_material(0, bag_yellow)
			first_bag.bagmesh.set_surface_override_material(1, bag_black)
	
	if Global.level == 0:
		
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
				var starter_pos : Vector2 = Vector2(starter_point.global_position.x, starter_point.global_position.z)
				move_prompt.modulate.a = prompt_alpha
				if (player_pos-starter_pos).length() > 0.5:
					tut_progress += 1
					boost_prompt.visible = true
			1:
				if move_prompt.visible:
					move_prompt.modulate.a = lerpf(move_prompt.modulate.a, 0.0, delta*10.0)
					move_prompt.visible = move_prompt.modulate.a > 0.05
				
				boost_prompt.modulate.a = prompt_alpha
			2:
				if boost_prompt.visible:
					boost_prompt.modulate.a = lerpf(boost_prompt.modulate.a, 0.0, delta*10.0)
					boost_prompt.visible = boost_prompt.modulate.a > 0.05
				
		#print()

func on_bag_collected():
	tut_progress = 2
	recuiter_npc.visible = true
