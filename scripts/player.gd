extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_right: Area2D = $AttackArea_Right
@onready var attack_area_left: Area2D = $AttackArea_Left


func _physics_process(delta: float) -> void:
	# Add the gravity.
	_add_gravity(delta)
		
	# Handle Jump
	_handle_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")

	# Flip
	_flip_character(direction)
	
	# Move
	_move_character(direction)

	# Attack
	_attack(direction)

	#
	move_and_slide()
	

	
################################################################################
# Handle jump
func _add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# Handle jump
func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


# Move Character
func _move_character(direction) -> void:
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


# Flip Character
func _flip_character(direction) -> void:
	if direction > 0:
		animated_sprite_2d.flip_h = false
		
	if direction < 0:
		animated_sprite_2d.flip_h = true


# Attack
func _attack(direction) -> void:
	if Input.is_action_just_pressed("attack"):
		if animated_sprite_2d.flip_h: # Flipped -> walking left
			attack_area_left.start_attack("normal")

		else: # Not Flipped -> walking right
			attack_area_right.start_attack("normal")
