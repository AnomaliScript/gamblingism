extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var spawn_point: Node2D = $SpawnPoint
@onready var player_sprite: Sprite2D = $CharacterBody2D/Sprite2D
@onready var player_shape: CollisionShape2D = $CharacterBody2D/CollisionShape2D

# Pick the physics layer you use for world/solids so the corpse collides.
# Example: layer 1 = World.
const CORPSE_LAYER: int = 1
const CORPSE_MASK:  int = 1  # collide with World (and the player if your player mask includes World)

func _ready() -> void:
	# start at spawn
	player.global_position = spawn_point.global_position
	# listen for deaths
	player.died.connect(_on_player_died)

func _on_player_died(death_pos: Vector2) -> void:
	_drop_corpse(death_pos)
	_teleport_player_to_spawn()

func _teleport_player_to_spawn() -> void:
	player.velocity = Vector2.ZERO
	player.rotation = 0.0
	player.scale = Vector2.ONE               # prevents “getting bigger” if spawn had scale
	player.global_position = spawn_point.global_position
	player.set_physics_process(true)         # if you ever disable it on death

func _drop_corpse(at_pos: Vector2) -> void:
	# Make a collideable “costume” using a StaticBody2D
	var corpse := StaticBody2D.new()
	corpse.global_position = at_pos
	corpse.collision_layer = CORPSE_LAYER
	corpse.collision_mask  = CORPSE_MASK
	add_child(corpse)

	# Visual: copy the player’s Sprite2D look
	var cs := Sprite2D.new()
	cs.texture = player_sprite.texture
	cs.region_enabled = player_sprite.region_enabled
	cs.region_rect = player_sprite.region_rect
	cs.flip_h = player_sprite.flip_h
	cs.flip_v = player_sprite.flip_v
	cs.modulate = player_sprite.modulate
	cs.z_index = player_sprite.z_index
	corpse.add_child(cs)

	# Collider: duplicate the player’s shape so it collides like the player
	var shape_node := CollisionShape2D.new()
	# Deep-copy the Shape resource so later edits don’t affect both
	if player_shape.shape:
		shape_node.shape = player_shape.shape.duplicate(true)
		shape_node.position = player_shape.position
		shape_node.rotation = player_shape.rotation
		shape_node.scale    = player_shape.scale
	corpse.add_child(shape_node)

	# Optional: rotate/settle the corpse a bit to look “dead”
	# cs.rotation = deg2rad(90)

	# Optional auto-cleanup (e.g., after 15s)
	# get_tree().create_timer(15.0).timeout.connect(corpse.queue_free)
