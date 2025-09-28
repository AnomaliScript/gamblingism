extends CharacterBody2D

signal died

var _spawn: Transform2D = Transform2D.IDENTITY
func set_from(node: Node2D) -> void: _spawn = node.global_transform
func get_spawn() -> Transform2D: 
	return _spawn

@onready var spawn_point: Node2D = $"../SpawnPoint"

# --- Config ---
const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const KILL_Y := 2000.0
const DASH_MULT: float = 1.5     # speed multiplier while dash held
var gravity : float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))

# (Optional) remember original collision masks to restore
var _orig_layer := 0
var _orig_mask := 0

func _ready() -> void:
	SpawnPoint.set_from(spawn_point)   # OK if you added it as "Respawn"
	_orig_layer = collision_layer
	_orig_mask = collision_mask
	# If you want to start at spawn on load:
	# global_transform = Respawn.get()

func _physics_process(delta: float) -> void:
	# Instant death if you fell off the map
	if _kill_conditions():
		velocity.x = 0.0
		velocity.y = 0.0
		await die()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal move (rename to your actual actions!)
	var dash := Input.is_action_pressed("dash")
	if Input.is_action_pressed("move_left"):
		velocity.x = -SPEED * (DASH_MULT if dash else 1.0)
	elif Input.is_action_pressed("move_right"):
		velocity.x =  SPEED * (DASH_MULT if dash else 1.0)
	else:
		velocity.x = 0.0

	move_and_slide()
	
func _kill_conditions():
	if (global_position.y > KILL_Y 
		or _on_hazard_detector_body_entered(self)
		# or condition
		):
		return true
	else:
		return false

func _on_hazard_detector_body_entered(body: Node2D):
	if body.is_in_group("hazards"):
		return true

# Single, authoritative death handler
func die() -> void:
	# Optional: play death anim, SFX, etc. before disabling
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Short delay for death feedback; adjust or remove as needed
	#await get_tree().create_timer(0.6).timeout

	emit_signal("died", self)  # Let the level/game manager react if needed
