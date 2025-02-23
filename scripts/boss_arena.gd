extends Node2D

@onready var slime_king: CharacterBody2D = $SlimeKing


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_music("res://assets/music/boss_fight.mp3")
