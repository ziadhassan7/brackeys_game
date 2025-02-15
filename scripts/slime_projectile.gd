extends Area2D


var direction = Vector2.ZERO
var speed = 200  # Default speed, can be changed when instantiating

func _process(delta):
	position += direction * speed * delta


func _on_area_entered(body: Area2D) -> void:
	if body.is_in_group("player_hitbox"):
		queue_free()  # Destroy bullet on impact
