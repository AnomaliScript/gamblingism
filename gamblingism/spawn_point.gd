extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var _spawn: Transform2D = Transform2D.IDENTITY
func set_from(node: Node2D) -> void: _spawn = node.global_transform
