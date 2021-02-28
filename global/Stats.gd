extends Node

# Score data
var hi = 0 setget set_hi
var points = 0 setget set_points
var rest = 5 setget set_rest
var level = 1 setget set_level

# Player data
enum Items {
	None,
	Dagger,
	Pickaxe,
}

var item setget set_item

func set_points(value):
	points = clamp(value, 0, 999999)
	if points > hi:
		self.hi = points

func set_hi(value):
	hi = clamp(value, 0, 999999)

func set_rest(value):
	rest = clamp(value, 0, 99)

func set_level(value):
	level = clamp(value, 0, 15)

func set_item(value):
	item = clamp(value, Items.None, Items.Pickaxe)
