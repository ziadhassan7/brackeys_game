extends Node


var score = 0
signal score_updated(new_score)
signal score_hidden()

func add_point():
	score += 1
	emit_signal("score_updated", score)
	
func reset_score():
	score = 0
	emit_signal("score_updated", score)
	
func hide_score_label():
	emit_signal("score_hidden")

################################################################################

var health = 3
signal health_changed(value)

func take_damage():
	health -= 1
	emit_signal("health_changed", health)
	
func restore_health():
	health = 3
	emit_signal("health_changed", health)
	

################################################################################

signal portal_opened()

func open_portal_to_boss_arena():
	emit_signal("portal_opened")
