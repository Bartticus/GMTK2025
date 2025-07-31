extends Node3D

const life_length = 0.7
@onready var life_timer : float = 0.0
@onready var sprite : Sprite3D = $ImpactSprite


func _ready() -> void:
	top_level = true
	

func _process(delta: float) -> void:
	if visible:
		life_timer += delta
		if life_timer > life_length: queue_free()
		life_timer = min(life_length, life_timer)
		
		var spiky_impact_lerp : float = life_timer / (life_length * 0.25)
		if spiky_impact_lerp > 1.0:
			sprite.visible = false
		if sprite.visible:
			spiky_impact_lerp = min(1.0, spiky_impact_lerp)
			sprite.frame = roundi(spiky_impact_lerp * 4.0)
			
