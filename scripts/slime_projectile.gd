extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var GRAVITY = 2000
var direction = Vector2.ZERO
var velocity = Vector2.ZERO  # Actual movement velocity
var shooting_speed = 0

func launch(speed: int, angle: float, dir: int):
	shooting_speed = speed
	direction = Vector2(cos(angle) * dir, sin(angle))  # Correct flipping logic

	# Flip sprite if moving left
	if dir < 0:
		sprite.flip_h = true  

func _process(delta):
	velocity += Vector2(0, GRAVITY) * delta  # Apply gravity
	position += (direction * shooting_speed + velocity) * delta  # Apply movement

func _on_area_entered(body: Area2D) -> void:
	print(body)
	if body.is_in_group("player"):
		queue_free()
