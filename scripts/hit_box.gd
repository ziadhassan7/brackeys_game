extends Area2D
# do not forget setting the mask to 2

@export var assigned_character : Node2D


######################################################
# Touched the player hit area (sword)
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		take_damage(area)

func take_damage(area: Area2D):
	assigned_character.take_damage(area.damage)


######################################################
# Touched the player itself
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		apply_damage(body)

func apply_damage(body: Node2D):
	body.death()
