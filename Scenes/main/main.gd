extends Node3D

@onready var ambi : AudioStreamPlayer = $"Street Ambi"


func _ready() -> void:
	Global.main = self
	get_viewport().connect("size_changed",Callable(self,"_root_viewport_size_changed"))
	


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pass#get_tree().quit()


func set_bag_count():
	$Control/Label.text = "Bags: " + str(Global.bags_gotten)

func _root_viewport_size_changed():
	$Control/Label.label_settings.font_size = get_viewport().size.y*0.07
