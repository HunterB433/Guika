extends RigidBody2D

@export var fruit_type: int = 1                    
@export var fruit_scenes: Array = []              
@export var score_value: int = 10                
@export var merge_y_threshold: float = -320      

var main: Node = null
var button: Node = null
var has_merged: bool = false

func _ready():
	main = get_tree().root.get_node("Main") if get_tree().root.has_node("Main") else null
	button = main.get_node("DeleteButton")

	var merge_area = $MergeArea
	if merge_area:
		merge_area.body_entered.connect(_on_body_entered)
	else:
		push_error("MergeArea not found for " + name)

	print("Fruit ready:", name, "Type:", fruit_type, "Position:", global_position)

func _on_body_entered(body: Node) -> void:
	if body == self:
		return


	if has_merged:
		return

	if body is RigidBody2D and body.has_method("get_fruit_type"):
		var other_type = body.get_fruit_type()
		
		if fruit_type == other_type \
		and global_position.y >= merge_y_threshold \
		and body.global_position.y >= merge_y_threshold:

			if get_instance_id() < body.get_instance_id():
				has_merged = true
				print("Merge conditions met! Merging now between", name, "and", body.name)
				call_deferred("_deferred_combine", body)

func _deferred_combine(other: RigidBody2D) -> void:
	if fruit_type >= fruit_scenes.size():
		print("Max fruit reached, BOOM")
		if main and main.has_method("increase_score"):
			main.increase_score(score_value)
		queue_free() 
		return

	var next_scene: PackedScene = fruit_scenes[fruit_type]
	if not next_scene:
		print("Next fruit scene missing for type:", fruit_type)
		return

	var new_fruit = next_scene.instantiate()
	
	if new_fruit.has_method("set_fruit_scenes"):
		new_fruit.set_fruit_scenes(fruit_scenes)
	
	new_fruit.global_position = (global_position + other.global_position) / 2
	get_parent().add_child(new_fruit)
	new_fruit.playPopSound()

	if main and main.has_method("increase_score"):
		main.increase_score(score_value)
	
	print("Merging fruits: freeing", name, "and", other.name)
	queue_free()
	other.queue_free()
	
func _solo_pop() -> void:
	if main and main.has_method("increase_score"):
		main.increase_score(score_value)
	queue_free()

func set_fruit_scenes(scenes: Array) -> void:
	fruit_scenes = scenes

func get_fruit_type() -> int:
	return fruit_type
	
func playPopSound():
	$Fuse.play()
	
func _on_merge_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if button.deleteMode:
			if button.boomsLeft > 0:
				button.boomsLeft -= 1
				print("Fruit clicked in DELETE mode! Bombs Left: ", button.boomsLeft)
				button.update_text()
				button.boom()
				_solo_pop()
			else:
				print("No booms")
		else:
			print("Fruit clicked, but delete mode is OFF")
