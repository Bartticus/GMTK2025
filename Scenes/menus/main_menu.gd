extends Control
@onready var sfx : AudioStreamPlayer = $uisfx
@onready var sfxH : AudioStreamPlayer = $uiHoversfx

func _on_play_pressed() -> void:
	sfx.play()
	get_tree().change_scene_to_file("res://Scenes/main/main.tscn")

func _on_credits_pressed() -> void:
	sfx.play()
	pass #insert credits here

func _on_quit_pressed() -> void:
	sfx.play()
	$PanelContainer/VBoxContainer/Quit.text = """This is a browser
	game lol"""


func _on_play_mouse_entered() -> void:
	sfxH.play()
	pass # Replace with function body.


func _on_credits_mouse_entered() -> void:
	sfxH.play()
	pass # Replace with function body.


func _on_quit_mouse_entered() -> void:
	sfxH.play()
	pass # Replace with function body.
