extends Node2D

const Player = preload("res://scenes/Player/Player.tscn")

const levels = {
	0: preload("res://scenes/Levels/Level00.tscn"),
	1: preload("res://scenes/Levels/Level01.tscn"),
	2: preload("res://scenes/Levels/Level02.tscn"),
	#3: preload("res://scenes/Levels/Level03.tscn"),
	#4: preload("res://scenes/Levels/Level04.tscn"),
	#5: preload("res://scenes/Levels/Level05.tscn"),
	#6: preload("res://scenes/Levels/Level06.tscn"),
	#7: preload("res://scenes/Levels/Level07.tscn"),
	#8: preload("res://scenes/Levels/Level08.tscn"),
	#9: preload("res://scenes/Levels/Level09.tscn"),
	#10: preload("res://scenes/Levels/Level10.tscn"),
	#11: preload("res://scenes/Levels/Level11.tscn"),
	#12: preload("res://scenes/Levels/Level12.tscn"),
	#13: preload("res://scenes/Levels/Level13.tscn"),
	#14: preload("res://scenes/Levels/Level14.tscn"),
	#15: preload("res://scenes/Levels/Level15.tscn"),
}

onready var level = $Level
onready var camera = $Camera2D

func _ready():
	load_level(0)

func load_level(level_number):
	if level.get_child_count() > 0:
		level.get_child(0).queue_free()
	var new_level = levels[level_number].instance()
	level.add_child(new_level)
	connect_signals()
	set_camera_limits(level_number)
	open_door()
	
func connect_signals():
	connect_doors()

func connect_doors():
	var doors = get_tree().get_nodes_in_group('DoorGroup')
	for door in doors:
		Utils.connect_signal(door, 'create_player', self, "on_create_player")

func open_door():
	var door = find_entrance_door()
	door.init()

func find_entrance_door():
	var final_door = null
	var statuses = ['entrada', 'entrada-salida']
	var doors = get_tree().get_nodes_in_group('DoorGroup')
	for door in doors:
		if statuses.has(door.door_type):
			final_door = door
			break
	return final_door

func set_camera_limits(level_number):
	camera.limit_left = 0
	camera.limit_top = -20
	camera.limit_bottom = 340
	camera.limit_right = 1280 if level_number % 2 == 0 else 640

func on_create_player(position):
	var player = Player.instance()
	get_tree().current_scene.add_child(player)
	player.global_position = position
	player.remote_transform.remote_path = "../../Camera2D"

