extends RigidBody2D

@export var fruit_type: int = 1                     
@export var fruit_scenes: Array = []              
@export var score_value: int = 10                  
@export var merge_y_threshold: float = -420      

var main: Node = null
var has_merged: bool = false

func _ready():
	main = get_tree().root.get_node("Main") if get_tree().root.has_node("Main") else null

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

		# Only merge if same type and above merge threshold
		if fruit_type == other_type \
		and global_position.y >= merge_y_threshold \
		and body.global_position.y >= merge_y_threshold:

			# Only the fruit with the lower instance_id merges
			if get_instance_id() < body.get_instance_id():
				has_merged = true
				print("Merge conditions met! Merging now between", name, "and", body.name)
				call_deferred("_deferred_combine", body)

func _deferred_combine(other: RigidBody2D) -> void:
	if fruit_type >= fruit_scenes.size():
		print("Max fruit reached, BOOM")
		if main and main.has_method("increase_score2"):
			main.increase_score2(score_value)
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

	if main and main.has_method("increase_score2"):
		main.increase_score2(score_value)

	print("Merging fruits: freeing", name, "and", other.name)
	queue_free()
	other.queue_free()

func set_fruit_scenes(scenes: Array) -> void:
	fruit_scenes = scenes

func get_fruit_type() -> int:
	return fruit_type

func playPopSound():
	$Fuse.play()


func _on_merge_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Fruit clicked!")
		
