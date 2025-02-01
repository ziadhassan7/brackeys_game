extends Control

@onready var score_label: Label = $"CanvasLayer/Score Label"

# connect the score_updated signal to your _on_score_updated() function
func _ready():
	GameManager.connect("score_updated", Callable(self, "_on_score_updated"))
	GameManager.connect("score_hidden", Callable(self, "_on_hide_score_label"))

# change label text
func _on_score_updated(new_score):
	score_label.text = "Score: " + str(new_score)
	
func _on_hide_score_label():
	score_label.visible = false
