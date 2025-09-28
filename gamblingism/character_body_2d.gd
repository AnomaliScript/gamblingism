extends CharacterBody2D

signal died(dead: CharacterBody2D)

var _spawn: Transform2D = Transform2D.IDENTITY
func set_from(node: Node2D) -> void: _spawn = node.global_transform
func get_spawn() -> Transform2D: 
	return _spawn

@onready var spawn_point: Node2D = $"../SpawnPoint"
@onready var animated_sprite = $AnimatedSprite2D
# --- Config ---
const SPEED := 150.0
const JUMP_VELOCITY := -300.0
const KILL_Y := 2000.0
const DASH_MULT: float = 1.5     # speed multiplier while dash held
var gravity : float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var hazard_contact: bool = false


# (Optional) remember original collision masks to restore
var _orig_layer := 0
var _orig_mask := 0

func _ready() -> void:
	SpawnPoint.set_from(spawn_point)
	_orig_layer = collision_layer
	_orig_mask = collision_mask
	$"HazardSensor".body_entered.connect(func(_body): hazard_contact = true)
	$"HazardSensor".body_exited.connect(func(_body): hazard_contact = false)
	# If you want to start at spawn on load:
	#global_transform = SpawnPoint.get()

func _physics_process(delta: float) -> void:
	if _kill_conditions():
		velocity.x = 0.0
		velocity.y = 0.0
		await die()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	
	if (Input.is_action_just_released("move right") or Input.is_action_just_released("move left")) and is_on_floor() and not (Input.is_action_pressed("move left") and (Input.is_action_pressed("move right"))):
			animated_sprite.play("idle")
		

	# Horizontal move (rename to your actual actions!)
	var dash := Input.is_action_pressed("dash")
	if Input.is_action_just_pressed("move left"):
		velocity.x = -SPEED * (DASH_MULT if dash else 1.0)
		if is_on_floor():
			animated_sprite.play("leftRun")
	elif Input.is_action_just_pressed("move right"):
		velocity.x =  SPEED * (DASH_MULT if dash else 1.0)
		if  is_on_floor():
			animated_sprite.play("rightRun")
			
	
	else:
		velocity.x = 0.0
		if is_on_floor():
			animated_sprite.play("idle")
	move_and_slide()
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		if Input.is_action_pressed("move right"):
			animated_sprite.play("rightJump")
		elif Input.is_action_pressed("move left"):
			animated_sprite.play("leftJump")
		else:
			animated_sprite.play("staticJump")
	
func _kill_conditions():
	if (global_position.y > KILL_Y 
		or hazard_contact
		# or condition
		):
		return true
	else:
		return false

# Single, authoritative death handler
func die() -> void:
	# Optional: play death anim, SFX, etc. before disabling
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Short delay for death feedback; adjust or remove as needed
	#await get_tree().create_timer(0.6).timeout

	emit_signal("died", self)  # Let the level/game manager react if needed


func _on_animated_sprite_animation_changed(old_name: StringName, new_name: StringName) -> void:
	pass # Replace with function body.
