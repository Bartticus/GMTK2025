extends Camera3D

@onready var camera_shake : float = 0.0
@export var shake_noise : Noise
@onready var frequency : float = 0.0

func _process(delta: float) -> void:
	if camera_shake > 0.0:
		var shake_freq = frequency*5.0
		var shake_amount = 0.13 * camera_shake
		var sampler = shake_noise.get_noise_2d(shake_freq, 0.0)
		h_offset = lerp(0.0, shake_amount, sampler)
		sampler = shake_noise.get_noise_2d(0.0, shake_freq)
		v_offset = lerp(0.0, shake_amount, sampler)
		
		frequency += delta
	
	camera_shake = lerpf(camera_shake, 0.0, delta * 7.0)
