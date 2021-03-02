extends CanvasLayer

onready var rest_label = $HBoxContainer/RestLabel
onready var score_label = $HBoxContainer/ScoreLabel
onready var pyramid_label = $HBoxContainer/PyramidLabel
onready var hi_score_label = $HBoxContainer/HighScoreLabel

func _ready():
	update_score()

func update_score():
	score_label.text = "SCORE-%06d" % Stats.points
	hi_score_label.text = "HI-%06d" % Stats.hi
	rest_label.text = "REST-%02d" % Stats.rest
	pyramid_label.text = "PYRAMID-%02d" % Stats.level
	
func on_jewel_picked(_jewel):
	Stats.points += 500
	update_score()
	
