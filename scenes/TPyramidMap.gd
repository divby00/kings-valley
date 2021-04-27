class_name TPyramidMap extends ColorRect

signal sig_continue_level(level)

export (int,1,15) var from_level:int
export (int,1,16) var to_level:int

var pfrom:Sprite
var pto:Sprite

func _ready():
	for item in $Pyramids.get_children():
		item.visible=false

func run():
	Globals.playMusic(Globals.MUSICS.PYRAMIDMAP)
	pfrom = $Pyramids.get_child(from_level-1)
	pto = $Pyramids.get_child(to_level-1)

	pfrom.visible=true
	$Timer.start(0.5)
	yield($Timer,"timeout")

	for _i in range(1,4):
		pfrom.visible=true
		$Timer.start(0.3)
		yield($Timer,"timeout")
		pfrom.visible=false
		$Timer.start(0.3)
		yield($Timer,"timeout")
	
	for _i in range(1,4):
		pto.visible=true
		$Timer.start(0.3)
		yield($Timer,"timeout")
		pto.visible=false
		$Timer.start(0.3)
		yield($Timer,"timeout")
		
	pto.visible=true
	$Timer.start(1)
	yield($Timer,"timeout")
	emit_signal("sig_continue_level",to_level)		
