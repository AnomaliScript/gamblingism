extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var spawn: Node2D = $SpawnPoint
@onready var player_sprite: Sprite2D = $CharacterBody2D/Sprite2D

func _ready() -> void:
	var globals = get_node("/root/Globals")  # Absolute path to autoload
	globals.respawn_position = $SpawnPoint.global_position  # Assumes SpawnPoint is a child here
	# ensure player begins at spawn
	player.global_position = spawn.global_position
	# listen for death
	player.died.connect(_on_player_died)

func _on_player_died(dead: CharacterBody2D) -> void:
	_leave_corpse(dead)
	_respawn_same_player(dead)

func _leave_corpse(dead: CharacterBody2D) -> void:
	# make a "costume" corpse (plain Sprite2D) at the death spot
	var corpse := Sprite2D.new()
	corpse.global_position = dead.global_position
	corpse.rotation = 0.0            # set to deg2rad(90) if you want it to look fallen over
	corpse.z_index = 0               # bump if it appears behind tiles

	# copy visual from the player's Sprite2D
	corpse.texture = player_sprite.texture
	corpse.flip_h = player_sprite.flip_h
	corpse.flip_v = player_sprite.flip_v
	corpse.region_enabled = player_sprite.region_enabled
	corpse.region_rect = player_sprite.region_rect
	corpse.modulate = player_sprite.modulate

	add_child(corpse)

	# (optional) fade out & clean up after N seconds
	# get_tree().create_timer(10.0).timeout.connect(corpse.queue_free)

func _respawn_same_player(dead: CharacterBody2D) -> void:
	dead.velocity = Vector2.ZERO
	dead.global_position = spawn.global_position

	# Called when the node enters the scene tree for the first time.
	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
