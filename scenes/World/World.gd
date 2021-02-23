extends Node2D

const levels = {
	#0: preload("res://scenes/Levels/Level00.tscn"),
	1: preload("res://scenes/Levels/Level01.tscn"),
	2: preload("res://scenes/Levels/Level02.tscn"),
	3: preload("res://scenes/Levels/Level03.tscn"),
	4: preload("res://scenes/Levels/Level04.tscn"),
	5: preload("res://scenes/Levels/Level05.tscn"),
	6: preload("res://scenes/Levels/Level06.tscn"),
	7: preload("res://scenes/Levels/Level07.tscn"),
	8: preload("res://scenes/Levels/Level08.tscn"),
	9: preload("res://scenes/Levels/Level09.tscn"),
	10: preload("res://scenes/Levels/Level10.tscn"),
	11: preload("res://scenes/Levels/Level11.tscn"),
	12: preload("res://scenes/Levels/Level12.tscn"),
	13: preload("res://scenes/Levels/Level13.tscn"),
	14: preload("res://scenes/Levels/Level14.tscn"),
	15: preload("res://scenes/Levels/Level15.tscn"),
}

onready var level = $Level
onready var camera = $Camera2D

func _ready():
	load_level(1)

func load_level(level_number):
	if level.get_child_count() > 0:
		level.get_child(0).queue_free()
	var new_level = levels[level_number].instance()
	level.add_child(new_level)
	set_camera_limits(level_number)
	var jewels = get_tree().get_nodes_in_group('JewelGroup')
	print(len(jewels))

func set_camera_limits(level_number):
	camera.limit_left = 0
	camera.limit_top = -20
	camera.limit_bottom = 340
	camera.limit_right = 1280 if level_number % 2 == 0 else 640
