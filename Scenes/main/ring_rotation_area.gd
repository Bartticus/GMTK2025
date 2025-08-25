extends Area3D

@export var ring: Ring
@onready var parent_level: Level = get_parent()

func _on_body_entered(body: Node3D) -> void:
	if ring.levels[Global.level] != parent_level:
		ring.spin(parent_level)
