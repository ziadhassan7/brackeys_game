extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	print("You DIED!!")
	
	# slow motion effect & remove ground from the player
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	
	# start timer to reload scene
	timer.start()
	
	
func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0 # set time back to normal
	get_tree().reload_current_scene()
