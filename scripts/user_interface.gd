extends Control

@onready var score_label: Label = $"CanvasLayer/Score/Score Label"
@onready var score_sprite: Sprite2D = $CanvasLayer/Score/ScoreSprite
@onready var heart_1: Sprite2D = $CanvasLayer/Health/Heart1
@onready var heart_2: Sprite2D = $CanvasLayer/Health/Heart2
@onready var heart_3: Sprite2D = $CanvasLayer/Health/Heart3
@onready var boss_progress_bar: TextureProgressBar = $"CanvasLayer/Boss Progress Bar"


# connect the score_updated signal to your _on_score_updated() function
func _ready():
	GameManager.connect("score_updated", Callable(self, "_on_score_updated"))
	GameManager.connect("score_hidden", Callable(self, "_on_hide_score_label"))
	GameManager.connect("health_changed", Callable(self, "_on_health_changed"))
	GameManager.connect("boss_health_changed", Callable(self, "_on_boss_health_changed"))
	GameManager.connect("boss_health_shown", Callable(self, "_on_boss_health_shown"))

	boss_progress_bar.visible = false


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

# Boss Health
func _on_boss_health_shown(max_health):	
	boss_progress_bar.visible = true
	boss_progress_bar.max_value = max_health
	boss_progress_bar.value = max_health

func _on_boss_health_changed(health):	
	boss_progress_bar.value = health


# Score
func _on_score_updated(new_score):
	score_label.text = str(new_score)
	
func _on_hide_score_label():
	score_label.visible = false
	score_sprite.visible = false
