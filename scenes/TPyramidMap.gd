class_name TPyramidMap extends ColorRect

signal sig_continue_level(level)

export (int, 1, 15) var from_level: int
export (int, 1, 16) var to_level: int

onready var pyramids = $Pyramids
onready var timer = $Timer

var pfrom: Sprite
var pto: Sprite


func _ready():
	for item in pyramids.get_children():
		item.visible = false


func run():
	Globals.play_music(Globals.MUSICS.PYRAMIDMAP)
	pfrom = pyramids.get_child(from_level - 1)
	pto = pyramids.get_child(to_level - 1)

	pfrom.visible = true
	timer.start(0.5)
	yield(timer, "timeout")

	for _i in range(1, 4):
		pfrom.visible = true
		timer.start(0.3)
		yield(timer, "timeout")
		pfrom.visible = false
		timer.start(0.3)
		yield(timer, "timeout")

	for _i in range(1, 4):
		pto.visible = true
		timer.start(0.3)
		yield(timer, "timeout")
		pto.visible = false
		timer.start(0.3)
		yield(timer, "timeout")

	pto.visible = true
	timer.start(1)
	yield(timer, "timeout")
	emit_signal("sig_continue_level", to_level)
