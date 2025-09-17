extends Node2D

@export var move_speed := 400.0

const FRUIT_SCENES = [
	preload("res://Suika/Scenes/Nfruit1.tscn"), 
	preload("res://Suika/Scenes/Nfruit2.tscn"),
	preload("res://Suika/Scenes/Nfruit3.tscn"), 
	preload("res://Suika/Scenes/Nfruit4.tscn"), 
	preload("res://Suika/Scenes/Nfruit5.tscn"), 
	preload("res://Suika/Scenes/Nfruit6.tscn"), 
	preload("res://Suika/Scenes/Nfruit7.tscn"), 
	preload("res://Suika/Scenes/Nfruit8.tscn"), 
	preload("res://Suika/Scenes/Nfruit9.tscn"), 
	preload("res://Suika/Scenes/Nfruit10.tscn")
]

# Constant array of fruit chances based on drop percentage
const FRUIT_CHANCES = [60,40,30,18,10,2]

var preview_fruit: RigidBody2D = null
var current_fruit_scene = null
var last_click_time: float = 0.0
var click_cooldown: float = 350     
var fruit_timer = {}


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
	return FRUIT_SCENES[0] 

func ready_fruit():
	current_fruit_scene = get_random_fruit_scene()
	preview_fruit = current_fruit_scene.instantiate()
	
	# Assign fruit scenes immediately
	if preview_fruit.has_method("set_fruit_scenes"):
		preview_fruit.set_fruit_scenes(FRUIT_SCENES)
	
	add_child(preview_fruit)
	
	# Position above the spawner
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

func _ready() -> void:
	ready_fruit()

func _input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		var current_time = Time.get_ticks_msec()
		if current_time - last_click_time >= click_cooldown:
			drop_fruit()
			last_click_time = current_time


func _process(delta: float) -> void:
	var dir := 0
	if Input.is_action_pressed("ui_left"):
		dir = -1
	if Input.is_action_pressed("ui_right"):
		dir = 1
	if(dir == 1 && position.x <= 160):
		position.x += dir * move_speed * delta
	elif(dir == -1 && position.x >= -360):
		position.x += dir * move_speed * delta
	
	# Clean
	for fruit in fruit_timer.keys():
		if not is_instance_valid(fruit):
			fruit_timer.erase(fruit)
			continue
	
	# Fruit timer
	for fruit in fruit_timer.keys():
		if fruit.global_position.y < -320:
			fruit_timer[fruit] += delta
		else:
			fruit_timer[fruit] = 0.0
		# GG
		if fruit_timer[fruit] >= 5.0:
			print(fruit.name, "has been above -320 for 5 seconds!")
			queue_free()
