extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main/main.tscn")

func _on_credits_pressed() -> void:
	pass #insert credits here

func _on_quit_pressed() -> void:
	$PanelContainer/VBoxContainer/Quit.text = """This is a browser
	game lol"""
