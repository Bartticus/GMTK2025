extends Node3D

@onready var npcComponent = $NpcComponent

func _ready() -> void:
	npcComponent.voiceSFX = $voice
	#npcComponent.voiceSFX.stream
