tool
class_name TDoorGiratory extends StaticBody2D

enum DIRECTION { LEFT = 1, RIGHT = 0 }

onready var tiles = $Tiles
onready var timer = $Timer
onready var brick = $Brick
onready var detector = $Zone/Detector

export (int, 1, 10) var height: int = 1 setget set_height
export (DIRECTION) var direction = DIRECTION.RIGHT setget set_direction

var index_right = 180
var index_left = 198


func _ready():
	var titem = load("res://scenes/items/TItem.tscn")
	while tiles.get_child_count() > 0:
		tiles.remove_child(tiles.get_child(0))
	for i in range(0, height):
		var item = titem.instance()
		var index = index_right if direction == DIRECTION.RIGHT else index_left
		item.set_init_frame(index)
		item.position.y = i * 10
		tiles.add_child(item)
		item = titem.instance()
		item.set_init_frame(index + 1)
		item.position.y = i * 10
		item.position.x = 10
		tiles.add_child(item)
# warning-ignore:integer_division
	var size = (height * 10) / 2
	brick.position.y = size
	brick.get_shape().set_extents(Vector2(3, size))
	detector.position.y = size
	detector.get_shape().set_extents(Vector2(3, size))
	if direction == DIRECTION.RIGHT:
		detector.position.x = 3
	else:
		detector.position.x = 18


func set_direction(d):
	direction = d


func set_height(h):
	height = h


func do_rotation(Vick):
	Globals.play_sound(Globals.snd_rotadoor)
	Vick.state = Vick.st_giratory
	self.remove_child(brick)
# warning-ignore:unused_variable
	for itera in range(0, 9):
		for i in tiles.get_children():
			if direction == DIRECTION.RIGHT:
				i.set_init_frame(i.getInitFrame() + 2)
				Vick.input_vector.x = 1
			else:
				i.set_init_frame(i.getInitFrame() - 2)
				Vick.input_vector.x = -1
		timer.start(0.1)
		yield(timer, "timeout")
	if direction == DIRECTION.RIGHT:
		direction = DIRECTION.LEFT
		detector.position.x = 15
	else:
		direction = DIRECTION.RIGHT
		detector.position.x = 5
	Vick.state = Vick.st_walk
	self.add_child(brick)


func _on_Zone_body_entered(body):
	if body.get_class() == "TVick" && body.state != body.st_giratory:
		if body.position.y <= self.position.y + height * 10:
			do_rotation(body)
