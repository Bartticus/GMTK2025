extends Node3D

@export var dialogue : DialogueResource
@onready var in_range : bool = false
@onready var npc : Node3D = get_parent()

@onready var e_prompt : Sprite3D = $E

@export var hover_curve : Curve
@onready var going_down : bool = false
@onready var height_lerp : float = 0.0

func _ready() -> void:
	$TalkArea.body_entered.connect(on_body_entered)
	$TalkArea.body_exited.connect(on_body_exited)




func _process(delta: float) -> void:
	
	
	if in_range and npc.visible:
		e_prompt.modulate.a = lerpf(e_prompt.modulate.a, 1.0, delta * 10.0)
	
		if Input.is_action_just_pressed("talk"):
			Global.player.talking = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			#elif event is InputEventMouseButton:
				#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			var balloon : Object = DialogueManager.show_example_dialogue_balloon(dialogue)#"res://Levels/Dialogue/recruiter.dialogue"
			print(balloon)
	else:
		e_prompt.modulate.a = lerpf(e_prompt.modulate.a, 0.0, delta * 10.0)
	
	if e_prompt.modulate.a > 0.05:
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
		
		e_prompt.position.y = lerpf(0.645, 0.745, hover_curve.sample_baked(height_lerp))








func on_body_entered(body : Node3D):
	if body == Global.player:
		in_range = true
	
func on_body_exited(body : Node3D):
	if body == Global.player:
		in_range = false
