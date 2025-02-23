extends CanvasLayer

@onready var win_screen: CanvasLayer = $"."
@onready var replay_button: Button = $Panel/Button


func _ready():
	replay_button.connect("pressed", Callable(self, "_on_restart_pressed"))
	win_screen.visible = false


func open():
	win_screen.visible = true

func close():
	win_screen.visible = false


func _on_restart_pressed():
	close()
	get_tree().change_scene_to_file("res://scenes/Levels/level_1.tscn")
	GameManager.hide_boss_health()
