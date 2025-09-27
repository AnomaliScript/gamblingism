extends CharacterBody2D

signal died

var _spawn: Transform2D = Transform2D.IDENTITY
func set_from(node: Node2D) -> void: _spawn = node.global_transform
func get() -> Transform2D: return _spawn

@onready var spawn_point: Node2D = $SpawnPoint

# --- Config ---
const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const KILL_Y := 2000.0
var gravity : float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))

# (Optional) remember original collision masks to restore
var _orig_layer := 0
var _orig_mask := 0

func _ready() -> void:
	Respawn.set_from(spawn_point)   # OK if you added it as "Respawn"
	_orig_layer = collision_layer
	_orig_mask = collision_mask
	# If you want to start at spawn on load:
	# global_transform = Respawn.get()

func _physics_process(delta: float) -> void:
	# Instant death if you fell off the map
	if global_position.y > KILL_Y:
		await die()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal move (rename to your actual actions!)
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

func _on_hazard_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("hazards"):
		await die()

# Single, authoritative death handler
func die() -> void:
	# Optional: play death anim, SFX, etc. before disabling
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO

	# Short delay for death feedback; adjust or remove as needed
	await get_tree().create_timer(0.6).timeout

	emit_signal("died")  # Let the level/game manager react if needed
	respawn()

func respawn() -> void:
	# Use your autoload (adjust if your singleton name differs)
	# Expecting Respawn.get() -> Transform2D
	global_transform = Respawn.get()

	velocity = Vector2.ZERO
	collision_layer = _orig_layer
	collision_mask = _orig_mask
	set_physics_process(true)
