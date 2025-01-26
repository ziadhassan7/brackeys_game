extends Node2D

const SPEED = 60

var direction = 1 # 1: right , -1: left

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
	
	position.x += direction*(SPEED * delta) #we multiply by delta because the time between frames varies and we do not want the speed to be fluctuating, so we use delta to stablize the speed by overcompensating  the difference between each frame. 
