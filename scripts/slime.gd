extends Node2D

const MAX_HEALTH = 21

var speed = 60
var direction = 1 # 1: right , -1: left
var health = MAX_HEALTH
var is_dead = false

@onready var hit_box: Area2D = $HitBox
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $HurtSound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead:
		return
	
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
		hit_box.scale.x = -1
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
		hit_box.scale.x = 1
		
	
	position.x += direction*(speed * delta) #we multiply by delta because the time between frames varies and we do not want the speed to be fluctuating, so we use delta to stablize the speed by overcompensating  the difference between each frame.
	


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
		hit_box.set_deferred("monitoring", false)
		hit_box.set_deferred("visible", false)  
		# Reset to idle after the hurt animation finishes
		await animated_sprite_2d.animation_finished  
		animated_sprite_2d.play("idle") 
		# Re-enable the hitbox
		if is_instance_valid(hit_box):
			hit_box.set_deferred("monitoring", true)
			hit_box.set_deferred("visible", true)



func die():
	if is_dead:
		return

	is_dead = true

	speed = 5  # Stop movement
	animated_sprite_2d.play("death")  # Play death animation
	hit_box.queue_free() # turn off enemy killzone
	
	await animated_sprite_2d.animation_finished
	queue_free()  # Remove enemy after animation 
	
	GameManager.open_portal_to_boss_arena()
