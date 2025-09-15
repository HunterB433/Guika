extends Button

var deleteMode := false
var boomsLeft := 5

func _ready():
	pressed.connect(_on_button_pressed)

func update_text():
	if deleteMode:
		text = "Bomb ON " + str(boomsLeft) + "/5"
	else:
		text = "Bomb OFF " + str(boomsLeft) + "/5"

func _on_button_pressed():
	deleteMode = !deleteMode
	update_text()

func boom():
	$Explode.play()
