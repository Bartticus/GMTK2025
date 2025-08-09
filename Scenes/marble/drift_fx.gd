extends Node3D


@onready var currently_drifting : bool = false
@onready var drifting_timer : float = 0.0
@onready var drift_lerp : float = 0.0
@onready var current_move_rot : float = 0.0#Vector2 = Vector2.ZERO

@onready var y_rot : float = 0.0

@onready var alpha : float = 0.0
@onready var arrow : Sprite3D = $GroundPath

@onready var sprites : Array = [$Sprites, $Sprites/Sprite1, $Sprites/Sprite2, $Sprites/Sprite3, $Sprites/Sprite4]
@onready var small_sprites : Array = [$Sprites/SmallSprite1, $Sprites/SmallSprite2]
@onready var sprites_frame_timer : float = 0.0
@onready var small_sprites_frame_timer : float = 0.1

@export var start_color : Color
@export var end_color : Color
@export var intensity_curve : Curve

@export var marble: Marble

func _process(delta: float) -> void:
	global_transform.basis = Basis.IDENTITY
	
	y_rot = lerp_angle(y_rot, current_move_rot, delta*8.0)
	
	rotate_y(y_rot)
	
	if currently_drifting:
		alpha = lerpf(alpha, 0.9, delta*10.0)
		#drifting_timer += delta
		#drift_lerp = drifting_timer / 2.0
		#drift_lerp = min(drift_lerp, 1.0)
		
		#drift_lerp = intensity_curve.sample_baked(drift_lerp)
		
		drift_lerp = lerpf(drift_lerp, marble.rot_speed_factor * 2.0, delta * 2.0)
		
		arrow.position.z = lerpf(0.45, 0.025, drift_lerp)
		arrow.scale = Vector3.ONE * lerpf(0.6, 0.7, drift_lerp)
		
		var sprite_color : Color = start_color
		sprites[0].modulate = sprite_color.lerp(end_color, drift_lerp)
	else:
		#if drifting_timer > 0.0:
		alpha = 0.0
		#drifting_timer = 0.0
		drift_lerp = 0.0
		
	sprites[0].modulate.a = alpha
	arrow.modulate.a = alpha
	
	if alpha > 0.1:
		sprites_frame_timer += delta
		small_sprites_frame_timer += delta
		if sprites_frame_timer > 0.025:
			sprites_frame_timer = 0.0
			for sprite in sprites:
				if sprite.frame == 5:
					sprite.frame = 0
					if randi() % 2:
						sprite.flip_h = !sprite.flip_h
				else:
					sprite.frame += 1
		
		if small_sprites_frame_timer > 0.04:
			small_sprites_frame_timer = 0.0
			$Sprites/Sprite.rotate_y(randf())
			if randi() % 2:
				$Sprites/SpriteStatic.flip_h = !$Sprites/SpriteStatic.flip_h
			for sprite in small_sprites:
				if sprite.frame == 3:
					sprite.frame = 0
				else:
					sprite.frame += 1
	
