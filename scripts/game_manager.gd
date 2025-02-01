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

signal portal_opened()

func open_portal_to_boss_arena():
	emit_signal("portal_opened")
