extends Area2D

@onready var portal_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var portal_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

var boss_arena_scene: PackedScene = preload("res://scenes/Levels/boss_arena.tscn")


func _ready():
	GameManager.connect("portal_opened", Callable(self, "_open_portal"))
	portal_animation.modulate.a = 0.0 # Initially set alpha to 0
	collision_shape.disabled = true

func _on_body_entered(body: Node2D) -> void:
	SceneManager.change_scene_to(boss_arena_scene)
	GameManager.hide_score_label()
	body.start_portal_animation()


func _open_portal():
	fade_in_animation(2.0)
	collision_shape.disabled = false
	
	MusicManager.lower_volum(0.6) # Lower scene music
	fade_in_sound_effect(2.0)



# Fade in Effects ##############################################################
func fade_in_animation(fade_duration: float = 2.0) -> void:	
	var tween = get_tree().create_tween()
	# Tween the alpha component of modulate from 0 to 1.
	tween.tween_property(portal_animation, "modulate:a", 1.0, fade_duration)

func fade_in_sound_effect(fade_duration: float = 2.0) -> void:
	var original_volum = portal_sound.volume_db
	# Start from very low volume (silence)
	portal_sound.volume_db = -80  # -80 dB is effectively silent
	portal_sound.play()
	
	# Create a Tween to interpolate volume_db from -80 to 0 over fade_duration seconds.
	var tween = get_tree().create_tween()
	tween.tween_property(portal_sound, "volume_db", original_volum, fade_duration)
