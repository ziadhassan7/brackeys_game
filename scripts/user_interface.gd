extends Control

@onready var score_label: Label = $"CanvasLayer/Score/Score Label"
@onready var score_sprite: Sprite2D = $CanvasLayer/Score/ScoreSprite
@onready var heart_1: Sprite2D = $CanvasLayer/Health/Heart1
@onready var heart_2: Sprite2D = $CanvasLayer/Health/Heart2
@onready var heart_3: Sprite2D = $CanvasLayer/Health/Heart3


# connect the score_updated signal to your _on_score_updated() function
func _ready():
	GameManager.connect("score_updated", Callable(self, "_on_score_updated"))
	GameManager.connect("score_hidden", Callable(self, "_on_hide_score_label"))
	GameManager.connect("health_changed", Callable(self, "_on_health_changed"))


# Health
func _on_health_changed(health):	
	if health == 2:
		heart_3.visible = false
	elif health == 1:
		heart_3.visible = false
		heart_2.visible = false
	elif health == 0:
		heart_3.visible = false
		heart_2.visible = false
		heart_1.visible = false


# Score
func _on_score_updated(new_score):
	score_label.text = str(new_score)
	
func _on_hide_score_label():
	score_label.visible = false
	score_sprite.visible = false
