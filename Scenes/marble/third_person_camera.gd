extends Camera3D

@export var spring_arm: Node3D
@export var lerp_power: float = 1.0

@onready var camera_shake : float = 0.0
@export var shake_noise : Noise
@onready var frequency : float = 0.0
@onready var pivot_rotation : float = 0.0

@export var zoom_curve : Curve

const zoom_duration : float = 10.0
@onready var zoom_timer : float = 0.0
@onready var zoomin : bool = true

func _process(delta: float) -> void:
	
	if zoomin:
		zoom_timer += delta
		if Input.is_action_pressed("click"):
			zoom_timer += delta * 5.0
		zoom_timer = min(zoom_duration, zoom_timer)
		
		Global.main.zoom_path_follow.progress_ratio = zoom_curve.sample_baked(zoom_timer/zoom_duration)
		global_transform = Global.main.zoom_path_follow.global_transform
		
		zoomin = zoom_timer < zoom_duration*0.96
		if !zoomin:
			transform.basis = Basis.IDENTITY
	else:
		position = lerp(position, spring_arm.position, delta * lerp_power)
	
	if camera_shake > 0.0:
		var shake_freq = frequency*5.0
		var shake_amount = 0.13 * camera_shake
		var sampler = shake_noise.get_noise_2d(shake_freq, 0.0)
		h_offset = lerp(0.0, shake_amount, sampler)
		sampler = shake_noise.get_noise_2d(0.0, shake_freq)
		v_offset = lerp(0.0, shake_amount, sampler)
		
		frequency += delta
	
	camera_shake = lerpf(camera_shake, 0.0, delta * 7.0)
