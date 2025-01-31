extends Node2D

const SPEED = 60
const MAX_HEALTH = 200

var direction = 1 # 1: right , -1: left
var health = MAX_HEALTH
var is_dead = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone: Area2D = $Killzone
@onready var slime: Area2D = $"."
@onready var death_sound: AudioStreamPlayer2D = $DeathSound


# assign signal to detect if enemy is being hit (by using the built in area_entered)
func _ready():
	slime.connect("area_entered", Callable(self, "_on_hit"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
	
	position.x += direction*(SPEED * delta) #we multiply by delta because the time between frames varies and we do not want the speed to be fluctuating, so we use delta to stablize the speed by overcompensating  the difference between each frame.
	


# When enemy is hit by the player
func _on_hit(body: Area2D):
	print(body.name)
	if body.is_in_group("player_hitbox"): # do not forget setting the mask to 2
		take_damage()


func take_damage():
	if is_dead:
		return

	health -= 1
	animated_sprite_2d.play("hurt") 
	death_sound.set_deferred("playing", true)
	# Disable the hitbox temporarily
	killzone.set_deferred("monitoring", false)
	killzone.set_deferred("visible", false)  
	
	# Reset to idle after the hurt animation finishes
	await animated_sprite_2d.animation_finished  
	animated_sprite_2d.play("idle") 
	# Re-enable the hitbox
	killzone.set_deferred("monitoring", true)
	killzone.set_deferred("visible", true)

	# health reached 0 => DEAD
	if health <= 0:
		die()



func die():
	is_dead = true
	animated_sprite_2d.play("death")  # Play death animation
	await animated_sprite_2d.animation_finished
	queue_free()  # Remove enemy after animation 
