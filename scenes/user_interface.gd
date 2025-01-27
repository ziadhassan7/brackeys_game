extends Control

@onready var game_manager: Node = %GameManager
@onready var score_label: Label = $"CanvasLayer/Score Label"


func _ready():
	if game_manager:
		game_manager.connect("score_updated", Callable(self, "_on_score_updated"))

func _on_score_updated(new_score):
	score_label.text = "Score: " + str(new_score)
