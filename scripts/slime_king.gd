extends CharacterBody2D

enum BossState{
	IDLE, JUMPING, SHOOTING, EAT
}

const SPEED = 60
const JUMP_FORCE = -300  # Negative because Y-axis is inverted in Godot
const GRAVITY = 500      # Simulated gravity
const JUMP_COUNT = 3     # Number of jumps before stopping

var MAX_HEALTH = 100

var current_state = BossState.IDLE
var current_speed = 60
var health = MAX_HEALTH
var is_dead = false
var jump_remaining = 0  # Track remaining jumps
var direction = -1

@onready var hit_box: Area2D = $HitBox
@onready var killzone: Area2D = $Killzone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $HurtSound
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var eye_ray_cast: RayCast2D = $EyeRayCast


@export var bullet_scene: PackedScene  # Assign `bullet.tscn` in the Inspector
@onready var mouth_position = $Mouth  # A Marker2D where bullets spawn

var shot_angles = [-70, -60, -50, -40, -30]  # Angles for each bullet
var shooting_speed = [650, 700, 750, 800, 850]
var shot_index = 0  # Tracks which bullet we're firing
var is_shooting = false



# assign signal to detect if enemy is being hit (by using the built in area_entered)
func _ready():
	hit_box.connect("area_entered", Callable(self, "_on_hit"))
	jump_remaining = JUMP_COUNT



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_add_gravity(delta)

	_flip_when_collide()
	
	_initiate_boss_attack_pattern()

	_add_movement()




## State Machine
func _initiate_boss_attack_pattern():
	match current_state:
		BossState.IDLE:
			await get_tree().create_timer(1.2).timeout # wait
			current_state = BossState.JUMPING
		
		BossState.JUMPING:
			_start_jumping_attack()
		
		BossState.SHOOTING:
			_start_shooting()
		
		BossState.EAT:
			_eat()


func _eat():
	pass


func _start_jumping_attack():
	if is_on_floor():
		if jump_remaining > 0:
			jump()
		else: # reset 
			jump_remaining = JUMP_COUNT
			current_speed = SPEED
			current_state = BossState.SHOOTING


func _start_shooting():
	if is_shooting: return
	
	is_shooting = true
	current_speed = 0  # Stop movement when shooting
	
	_flip_towards_player()

	for i in range(5):  # Loop to fire 5 bullets sequentially
		fire_next_bullet(i)
		await get_tree().create_timer(1).timeout  # Wait for 1 second between shots

	current_state = BossState.IDLE  # Return to idle after shooting
	shot_index = 0  # Reset the shot index for the next attack
	is_shooting = false

func fire_next_bullet(index):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = mouth_position.global_position
	get_tree().current_scene.add_child(bullet)  # Add bullet first!

	var angle = deg_to_rad(shot_angles[index])
	var speed = shooting_speed[index]
	bullet.launch(speed, angle, direction)  # Call launch after adding bullet



## Character Specific Functions

# Function to make the boss jump
func jump():
	if jump_remaining > 0:
		current_speed += 150
		velocity.y = JUMP_FORCE  # Apply jump force
		jump_remaining -= 1  # Decrease jump count


func _flip_when_collide():
	if ray_cast_right.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = true
		killzone.scale.x = -1
		
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = false
		killzone.scale.x = 1

func _flip_towards_player():
	var player = get_tree().get_nodes_in_group("player")[0]  # Get player reference
	if not eye_ray_cast.is_colliding() or eye_ray_cast.get_collider() != player:
		# Determine if the player is to the right or left
		if player.global_position.x > global_position.x:
			direction = 1
			animated_sprite_2d.flip_h = true
			killzone.scale.x = 1
		else:
			direction = -1
			animated_sprite_2d.flip_h = false
			killzone.scale.x = -1


## Basic Functions

func _add_movement():
	velocity.x = direction * current_speed 
	move_and_slide()

# Gravity
func _add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# When enemy is hit by the player
func _on_hit(hitbox: Area2D):
	if hitbox.is_in_group("player_hitbox"): # do not forget setting the mask to 2
		take_damage(hitbox.damage)


func take_damage(damage: int):
	if is_dead:
		return

	health -= damage
	GameManager.change_boss_health(health)

	# health reached 0 => DEAD
	if health <= 0:
		die()
	else:
		animated_sprite_2d.play("hurt") 
		death_sound.set_deferred("playing", true)
		# Disable the hitbox temporarily
		killzone.set_deferred("monitoring", false)
		killzone.set_deferred("visible", false)  
		# Reset to idle after the hurt animation finishes
		await animated_sprite_2d.animation_finished  
		animated_sprite_2d.play("idle") 
		# Re-enable the hitbox
		if is_instance_valid(killzone):
			killzone.set_deferred("monitoring", true)
			killzone.set_deferred("visible", true)


func die():
	if is_dead:
		return

	is_dead = true
	
	current_speed = 5  # Stop movement
	animated_sprite_2d.play("death")  # Play death animation
	killzone.queue_free() # turn off enemy killzone
	
	await animated_sprite_2d.animation_finished
	
	WinScreen.open()
	
	queue_free()  # Remove enemy after animation 
