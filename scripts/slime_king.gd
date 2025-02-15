extends CharacterBody2D


const MAX_HEALTH = 500
const JUMP_FORCE = -300  # Negative because Y-axis is inverted in Godot
const GRAVITY = 500      # Simulated gravity
const JUMP_COUNT = 3     # Number of jumps before stopping

var speed = 60
var health = MAX_HEALTH
var is_dead = false
var jump_remaining = 0  # Track remaining jumps

@onready var hit_box: Area2D = $HitBox
@onready var killzone: Area2D = $Killzone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $HurtSound
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft



# assign signal to detect if enemy is being hit (by using the built in area_entered)
func _ready():
	hit_box.connect("area_entered", Callable(self, "_on_hit"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	
	_add_gravity(delta)
	
	_flip_when_collide(direction)
	

	# If touching the ground, reset jumps
	if is_on_floor():
		if jump_remaining > 0:
			jump()
	
	
	velocity.x = direction * speed  # Set velocity instead of modifying position

	move_and_slide()


# Gravity
func _add_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# Function to make the boss jump
func jump():
	if jump_remaining > 0:
		velocity.y = JUMP_FORCE  # Apply jump force
		jump_remaining -= 1  # Decrease jump count


func _flip_when_collide(direction):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
		killzone.scale.x = -1
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
		killzone.scale.x = 1
		

# When enemy is hit by the player
func _on_hit(hitbox: Area2D):
	if hitbox.is_in_group("player_hitbox"): # do not forget setting the mask to 2
		take_damage(hitbox.damage)


func take_damage(damage: int):
	if is_dead:
		return

	health -= damage

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


	speed = 5  # Stop movement
	animated_sprite_2d.play("death")  # Play death animation
	killzone.queue_free() # turn off enemy killzone
	
	await animated_sprite_2d.animation_finished
	queue_free()  # Remove enemy after animation 
	
	is_dead = true
