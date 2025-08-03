extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var sfx : AudioStreamPlayer = $uisfx
@onready var sfxH : AudioStreamPlayer = $uiHoversfx

func _ready() -> void:
	hide()
	anim_player.play("RESET")

func resume() -> void:
	sfx.play()
	get_tree().set_deferred("paused", false)
	hide()
	anim_player.play_backwards("blur")

func pause() -> void:
	show()
	anim_player.play("blur")
	get_tree().set_deferred("paused", true)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		pause()
	if Input.is_action_just_pressed("ui_cancel") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	Global.level = 0
	Global.bags_gotten = 0
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	sfx.play()
	get_tree().quit()


func _on_resume_mouse_entered() -> void:
	sfxH.play()
	pass # Replace with function body.


func _on_restart_mouse_entered() -> void:
	sfxH.play()
	pass # Replace with function body.


func _on_quit_mouse_entered() -> void:
	sfxH.play()
	pass # Replace with function body.
