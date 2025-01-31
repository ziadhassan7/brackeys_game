extends Area2D	

var is_attacking = false

@onready var slash_animation: AnimatedSprite2D = $"Slash Animation"
@onready var hit_animation: AnimatedSprite2D = $"Hit Animation"
@onready var attack_area: Area2D = $"."
@onready var collision: CollisionShape2D = $CollisionShape2D

# Disable this node at the start
func _ready():
	attack_area.visible = false
	attack_area.monitoring = false
	collision.disabled = true


func start_attack(attack_type: String) -> void:
	if !is_attacking:
		# Start the attack
		is_attacking = true
		attack_area.visible = true
		attack_area.monitoring = true
		collision.disabled = false
		
		# Play the right attack animation
		if attack_type == "normal":
			play_small_attack()
		elif attack_type == "dash":
			play_dash_attack()
			
		# Disable hitbox after animation duration
		await get_tree().create_timer(0.3).timeout
		attack_area.visible = false
		attack_area.monitoring = false
		collision.disabled = true
		
		is_attacking = false # end the attack
		

func play_small_attack():
	slash_animation.play("small_slash")  # Play attack animation
	hit_animation.play("hit_1") 
	
	
func play_dash_attack():
	pass
