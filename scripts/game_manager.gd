extends Node

var score = 0
signal score_updated(new_score)

func add_point():
	score += 1
	emit_signal("score_updated", score)
