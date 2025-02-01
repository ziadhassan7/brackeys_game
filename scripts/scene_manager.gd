extends Node

@onready var fade_rect: ColorRect = $FadeRect


func _ready():
	fade_rect.modulate.a = 0
	

func change_scene_to(scene: PackedScene):
	# get_tree().change_scene_to_packed(scene)
	change_level_with_fade(scene)


################################################################################
func change_level_with_fade(scene: PackedScene, fade_duration: float = 1.0) -> void:
	# Fade out: tween the alpha from 0 to 1
	var tween = get_tree().create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished
	_on_fade_out_complete(scene)

func _on_fade_out_complete(scene: PackedScene, fade_duration: float = 1.0) -> void:
	get_tree().change_scene_to_packed(scene)
	
		# Fade in: tween the alpha from 1 to 0
	var tween = get_tree().create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0, fade_duration)
	await tween.finished
