extends Node

var score = 0
signal score_updated(new_score)

func add_point():
	score += 1
	emit_signal("score_updated", score)
	
func reset_score():
	score = 0
	emit_signal("score_updated", score)
