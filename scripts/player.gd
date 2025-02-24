extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ATTACK_TYPE = "dash" # There is also "normal"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_right: Area2D = $AttackArea_Right
@onready var attack_area_left: Area2D = $AttackArea_Left
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound

# Jump
@export var max_jump_velocity: float = -250.0  # Strongest jump
@export var min_jump_velocity: float = -50.0  # Weakest jump
@export var max_jumps: int = 2  # Max jumps allowed

var jumps_left_counter: int = max_jumps  # Remaining jumps
var is_jumping: bool = false  # Check if currently jumping
var health


# Dash
@export var dash_speed_multiplier := 1.9
@export var dash_duration_timer := 0.4
@export var dash_cooldown_timer := 1.0
var is_dashing := false
var can_dashing := false

var can_move = true


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")

	# Add the gravity.
	_add_gravity(delta)

	# Flip
	_flip_character(direction)

	# Move
	_move_character(direction)

	# Attack
	_attack(direction)
	
	if can_move:
		# Handle Dash
		_handle_dash(direction)
		# Handle Jump
		_handle_jump(delta)
		#
		move_and_slide()


	
################################################################################
# Gravity
func _add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# is_action_just_pressed : Triggers only once
# is_action_pressed : Keeps triggering continuously while the button is held

# Handle Jump
func _handle_jump(delta: float) -> void:
	# Jump Start: When jump is first pressed
	if Input.is_action_just_pressed("jump") and jumps_left_counter > 0:
		velocity.y = max_jump_velocity # strong (INITIAL) value as a boost.
		jumps_left_counter -= 1
		is_jumping = true
	
	# Holding Jump: Increase height based on hold time
	if Input.is_action_pressed("jump") and is_jumping:
		jumps_left_counter -= 1
		if velocity.y < max_jump_velocity:  # as long as we haven't reached the max jump
			velocity.y -= 10 # increase jump by small force GRADUALLY

	# Early Release: Reduce jump height if released early
	if Input.is_action_just_released("jump") and velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity # Force set to the minimum height (acts as brakes)
		is_jumping = false  # Stop increasing height

	# Reset Jumps When Landing
	if is_on_floor():
		jumps_left_counter = max_jumps
		is_jumping = false


# Handle Dash
func _handle_dash(direction) -> void:
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		sprite.play("dash")
		_start_dash()

func _start_dash() -> void:
	# Set dash velocity once when dash is triggered:
	if sprite.flip_h:
		velocity.x = -(SPEED * dash_speed_multiplier)
	else:
		velocity.x = (SPEED * dash_speed_multiplier)
		
	# Start a timer and then disable dash after dash_duration_timer seconds.
	await get_tree().create_timer(dash_duration_timer).timeout 
	is_dashing = false



# Move Character
func _move_character(direction) -> void:
	if not is_dashing: # make sure we're not dahsing (to not intervene the controls)
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)


# Flip Character
func _flip_character(direction) -> void:
	if direction > 0:
		sprite.flip_h = false
		
	if direction < 0:
		sprite.flip_h = true


# Attack
func _attack(direction) -> void:	
	
	if Input.is_action_just_pressed("attack"):
		if sprite.flip_h: # Flipped -> walking left
			attack_area_left.start_attack(ATTACK_TYPE)

		else: # Not Flipped -> walking right
			attack_area_right.start_attack(ATTACK_TYPE)


func damage():
	# if is_dashing: # desable taking damage if we are dashing
	#	return 
	
	# Play Damage animation
	sprite.play("damage")
	hurt_sound.set_deferred("playing", true)
	# Reset to idle after the hurt animation finishes
	await sprite.animation_finished  
	sprite.play("idle") 
	
	GameManager.take_damage()
	health = GameManager.health
	
	if health == 0: death()


# Death
func death() -> void:

	# Play Death animation
	sprite.play("death")

	# Slow motion effect & remove ground from the player
	Engine.time_scale = 0.5
	
	# Play Death Sound
	MusicManager.lower_volum() # lower backgound music to play death sound
	death_sound.play()
	await death_sound.finished
	MusicManager.reset_volum() # reset backgound music
	
	# Wait for 0.6 seconds before reloading the scene
	await get_tree().create_timer(0.6).timeout 
	
	# Set time back to normal & reload the scene
	Engine.time_scale = 1.0 
	get_tree().reload_current_scene()
	
	# Reset score & Health
	GameManager.reset_score()
	GameManager.restore_health() # reset health on death



# Fall Death
func fall_death() -> void:

	# Slow motion effect & remove ground from the player
	Engine.time_scale = 0.5
	
	# Disable player collision
	get_node("CollisionShape2D").queue_free()
	
	# Play Death Sound
	MusicManager.lower_volum() # lower backgound music to play death sound
	death_sound.play()
	await death_sound.finished
	MusicManager.reset_volum() # reset backgound music
	
	# Wait for 0.6 seconds before reloading the scene
	await get_tree().create_timer(0.6).timeout 
	
	# Set time back to normal & reload the scene
	Engine.time_scale = 1.0 
	get_tree().reload_current_scene()
	
	# Reset score & Health
	GameManager.reset_score()
	GameManager.restore_health() # reset health on death
