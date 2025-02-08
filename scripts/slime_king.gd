extends Area2D


const MAX_HEALTH = 500

var speed = 60
var direction = 1 # 1: right , -1: left
var health = MAX_HEALTH
var is_dead = false

@onready var slime_king: Area2D = $"."
@onready var killzone: Area2D = $Killzone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $HurtSound
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft



# assign signal to detect if enemy is being hit (by using the built in area_entered)
func _ready():
	slime_king.connect("area_entered", Callable(self, "_on_hit"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dead:
		return
	
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
		killzone.scale.x = -1
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
		killzone.scale.x = 1
		
	
	position.x -= direction*(speed * delta) 


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
