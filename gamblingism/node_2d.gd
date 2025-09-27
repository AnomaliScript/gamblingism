extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var globals = get_node("/root/Globals")  # Absolute path to autoload
	globals.respawn_position = $SpawnPoint.global_position  # Assumes SpawnPoint is a child here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
