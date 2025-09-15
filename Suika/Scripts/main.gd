extends Node2D  


@onready var score_label = $ScoreLabel
@onready var score_label2 = $ScoreLabel2


var score = 0
var score2 = 0

func _ready():
	update_label()

func update_label():
	score_label.text = "Score: %d" % score
	score_label2.text = "AIScr: %d" % score2
	
func increase_score(amount: int):
	score += amount
	print("Score is now: %d" % score)
	update_label()

func increase_score2(amount: int): 
	score2 += amount
	print("Score2 is now: %d" % score2)
	update_label()

func _process(delta: float) -> void:
	var player_exists = has_node("Player")
	var player2_exists = has_node("Player2")
	if not player_exists and not player2_exists:
		if score > score2:
			get_tree().change_scene_to_file("res://Suika/Scenes/Win.tscn")
		else:
			get_tree().change_scene_to_file("res://Suika/Scenes/Lose.tscn")
