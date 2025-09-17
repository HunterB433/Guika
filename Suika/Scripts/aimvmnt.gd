extends Node2D

@export var move_speed := 400.0
@export var min_drop_interval := .8
@export var max_drop_interval := 1.8
@export var left_bound := 50
@export var right_bound := 750
@export var smooth_factor := 5.0

const FRUIT_SCENES = [
	preload("res://Suika/Scenes/AIfruit1.tscn"), 
	preload("res://Suika/Scenes/AIfruit2.tscn"),
	preload("res://Suika/Scenes/AIfruit3.tscn"), 
	preload("res://Suika/Scenes/AIfruit4.tscn"), 
	preload("res://Suika/Scenes/AIfruit5.tscn"), 
	preload("res://Suika/Scenes/AIfruit6.tscn"), 
	preload("res://Suika/Scenes/AIfruit7.tscn"), 
	preload("res://Suika/Scenes/AIfruit8.tscn"), 
	preload("res://Suika/Scenes/AIfruit9.tscn"), 
	preload("res://Suika/Scenes/AIfruit10.tscn")
]

# Constant array of fruit chances based on drop percentage
const FRUIT_CHANCES = [60, 40, 30, 18, 10, 2]

var preview_fruit: RigidBody2D = null
var current_fruit_scene = null

var fruit_timer = {}
var cpu_target_x := 0.0
var drop_timer := 0.0

func get_random_fruit_scene():
	var total = 0
	for chance in FRUIT_CHANCES:
		total += chance
	var rand_num = randi() % total 
	var cumulative = 0
	for i in range(FRUIT_CHANCES.size()):
		cumulative += FRUIT_CHANCES[i]
		if rand_num < cumulative:
			return FRUIT_SCENES[i]
	return FRUIT_SCENES[0] # fallback

func ready_fruit():
	current_fruit_scene = get_random_fruit_scene()
	preview_fruit = current_fruit_scene.instantiate()
	
	if preview_fruit.has_method("set_fruit_scenes"):
		preview_fruit.set_fruit_scenes(FRUIT_SCENES)
	
	add_child(preview_fruit)
	
	var sprite := preview_fruit.get_node("Sprite2D")
	var sprite_height = sprite.texture.get_size().y * sprite.scale.y
	preview_fruit.global_position = global_position - Vector2(0, sprite_height / 2)
	preview_fruit.gravity_scale = 0.0

func drop_fruit():
	if not preview_fruit:
		return
	$DropSound.play()
	
	var drop_pos = global_position
	remove_child(preview_fruit)
	get_tree().root.get_child(0).add_child(preview_fruit)
	preview_fruit.global_position = drop_pos
	preview_fruit.gravity_scale = 1.0
	fruit_timer[preview_fruit] = 0.0
	
	
	preview_fruit = null
	ready_fruit()

func set_random_target():
	cpu_target_x = randf_range(left_bound, right_bound)

func reset_drop_timer():
	drop_timer = randf_range(min_drop_interval, max_drop_interval)

func _ready() -> void:
	ready_fruit()
	set_random_target()
	reset_drop_timer()

func _process(delta: float) -> void:
	var dir = cpu_target_x - position.x
	position.x += dir * smooth_factor * delta
	
	if abs(dir) < 5:
		set_random_target()
	
	drop_timer -= delta
	if drop_timer <= 0:
		drop_fruit()
		reset_drop_timer()
		
	# Clean
	for fruit in fruit_timer.keys():
		if not is_instance_valid(fruit):
			fruit_timer.erase(fruit)
			continue
	
	for fruit in fruit_timer.keys():
			if fruit.global_position.y < -320:
				fruit_timer[fruit] += delta
			else:
				fruit_timer[fruit] = 0.0
			# GG
			if fruit_timer[fruit] >= 5.0:
				print(fruit.name, "has been above -320 for 5 seconds!")
				queue_free()
