extends Button

func _on_pressed() -> void:
	var sceneName := name
	var scenePath := "res://Suika/Scenes/%s.tscn" % sceneName
	
	# Check it exists
	if ResourceLoader.exists(scenePath):
		get_tree().change_scene_to_file(scenePath)
	else:
		push_error("Scene not found ... [%s] (Did you forget to name the button
		Is your folder structure correct? Is the file in the correct place?)",scenePath)
