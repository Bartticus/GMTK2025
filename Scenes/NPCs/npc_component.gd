extends Node3D

@export var dialogue : DialogueResource
@export var character_visuals : Node3D
@onready var in_range : bool = false
@onready var npc : Node3D = get_parent()

@onready var e_prompt : Sprite3D = $E

@export var hover_curve : Curve
@onready var going_down : bool = false
@onready var height_lerp : float = 0.0

@onready var breathing_down : bool = false
@onready var breathing_timer: float = 0.0

@onready var squishing : bool = false
@export var squash_length : float = 0.35
@onready var squash_timer : float = 0.0
@onready var squash_intensity : float = 0.8

@onready var voiceSFX : AudioStreamPlayer3D = $Voice

func _ready() -> void:
	$TalkArea.body_entered.connect(on_body_entered)
	$TalkArea.body_exited.connect(on_body_exited)
	
	Global.dialogue_line_advance.connect(next_line)



func _process(delta: float) -> void:
	
	
	if in_range and npc.visible:
		e_prompt.modulate.a = lerpf(e_prompt.modulate.a, 1.0, delta * 10.0)
	
		if Input.is_action_just_pressed("talk") and !Global.player.talking:
			Global.player.talking = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			var balloon : Node = Global.balloon.instantiate()
			add_child(balloon)
			#get_tree().current_scene.add_child
			balloon.start(dialogue, "start")
			voiceSFX.play()
			
	else:
		e_prompt.modulate.a = lerpf(e_prompt.modulate.a, 0.0, delta * 10.0)
	
	
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
	
	if breathing_down:
		breathing_timer -= delta
		breathing_timer = max(breathing_timer, 0.0)
		if breathing_timer == 0.0:
			breathing_down = false
	else:
		breathing_timer += delta
		breathing_timer = min(breathing_timer, 1.0)
		if breathing_timer == 1.0:
			breathing_down = true
	
	
	
	if e_prompt.modulate.a > 0.05:
		e_prompt.position.y = lerpf(0.845, 0.945, hover_curve.sample_baked(height_lerp))
	
	var new_scale : Vector3 = Vector3.ONE
	if squishing:
		squash_timer -= delta
		squash_timer = max(squash_timer, 0.0)
		var squash_lerp : float = lerpf(1.0, 0.0, squash_timer / squash_length)
		
		new_scale.y += Global.player.visuals.squash_z_curve.sample_baked(squash_lerp) * squash_intensity
		new_scale.x += Global.player.visuals.squash_x_curve.sample_baked(squash_lerp) * squash_intensity
		new_scale.z += Global.player.visuals.squash_x_curve.sample_baked(squash_lerp) * squash_intensity
		
		if squash_timer == 0.0:
			squishing = false
			breathing_down = false
			breathing_timer = 0.5
	else:
		var breathing_scale : float = 0.08
		var breathing_lerp : float = hover_curve.sample_baked(breathing_timer) - 1.0
		new_scale.x += breathing_lerp * breathing_scale
		new_scale.z += breathing_lerp * breathing_scale
		new_scale.y -= breathing_lerp * breathing_scale
	character_visuals.scale = new_scale
	

func next_line():
	squash_timer = squash_length
	squishing = true
	voiceSFX.play()



func on_body_entered(body : Node3D):
	if body == Global.player:
		in_range = true
	
func on_body_exited(body : Node3D):
	if body == Global.player:
		in_range = false
