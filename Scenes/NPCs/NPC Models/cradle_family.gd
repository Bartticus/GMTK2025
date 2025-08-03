extends Node3D

func _ready() -> void:
	$Area3D.body_entered.connect(on_body_entered)
	$Area3D.body_exited.connect(on_body_exited)
	
	$NewtonsCradle.ouched.connect(on_ouched)




func on_ouched():
	$Voice3D.play()

func on_body_entered(body : Node3D):
	if body == Global.player:
		$NpcComponent.on_body_entered(body)
	
func on_body_exited(body : Node3D):
	if body == Global.player:
		$NpcComponent.on_body_exited(body)
