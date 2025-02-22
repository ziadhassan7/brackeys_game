extends Node2D

@onready var slime_king: CharacterBody2D = $SlimeKing

@export var max_boss_health = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music("res://assets/music/boss_fight.mp3")
	
	slime_king.MAX_HEALTH = max_boss_health
	GameManager.show_boss_health(max_boss_health)
