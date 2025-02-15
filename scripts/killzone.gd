extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): # do not forget setting the mask to 2
		body.death()
