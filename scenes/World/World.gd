extends Node2D

const Player = preload("res://scenes/Player/Player.tscn")
const MAX_JEWELS = 10

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
onready var score = $Score
onready var player = $Player
onready var camera = $Camera2D

var jewels_to_go setget set_jewels_to_go

func _ready():
	load_level(0)

func load_level(level_number):
	if level.get_child_count() > 0:
		level.get_child(0).queue_free()
	var new_level = levels[level_number].instance()
	level.add_child(new_level)
	self.jewels_to_go = find_jewels_to_go()
	connect_signals()
	set_camera_limits(level_number)
	Stats.level = level_number
	score.update_score()
	open_entrance_door()
	
func connect_signals():
	connect_jewels()
	connect_pickaxes()
	connect_daggers()
	connect_doors()

func connect_jewels():
	var jewels = get_tree().get_nodes_in_group('JewelGroup')
	for jewel in jewels:
		Utils.connect_signal(jewel, 'jewel_picked', self, 'on_jewel_picked')
		Utils.connect_signal(jewel, 'jewel_picked', score, 'on_jewel_picked')

func connect_pickaxes():
	var pickaxes = get_tree().get_nodes_in_group('PickaxeGroup')
	for pickaxe in pickaxes:
		Utils.connect_signal(pickaxe, 'pickaxe_picked', player, 'on_pickaxe_picked')

func connect_daggers():
	var daggers = get_tree().get_nodes_in_group('DaggerGroup')
	for dagger in daggers:
		Utils.connect_signal(dagger, 'dagger_picked', player, 'on_dagger_picked')

func connect_doors():
	var doors = get_tree().get_nodes_in_group('DoorGroup')
	for door in doors:
		Utils.connect_signal(door, 'hide_doors', self, 'on_hide_doors')
		Utils.connect_signal(door, 'prepare_player', self, 'on_prepare_player')

func open_entrance_door():
	var door = find_entrance_door()
	door.start()

func show_doors():
	var doors = get_tree().get_nodes_in_group('DoorGroup')
	for door in doors:
		door.visible = true

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
	camera.limit_right = 1024 if level_number % 2 == 0 else 640

func find_jewels_to_go():
	return len(get_tree().get_nodes_in_group('JewelGroup'))

func set_jewels_to_go(value):
	jewels_to_go = clamp(value, 0, MAX_JEWELS)
	if jewels_to_go == 0:
		show_doors()

func on_prepare_player(position):
	# Assign player position
	player.global_position = position
	# Attach the camera
	player.remote_transform.remote_path = "../../Camera2D"
	# Activate the player
	player.disabled = false
	# Reset player items
	Stats.item = Stats.Items.None

func on_jewel_picked(_jewel):
	self.jewels_to_go -= 1
	
func on_hide_doors():
	var doors = get_tree().get_nodes_in_group('DoorGroup')
	for door in doors:
		door.visible = false
		door.close()
