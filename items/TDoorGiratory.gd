tool
class_name TDoorGiratory extends StaticBody2D

enum DIRECTION {LEFT=1,RIGHT=0}

export (int,1,10) var height:int = 1 setget setHeight
export (DIRECTION) var direction = DIRECTION.RIGHT setget setDirection

var index_right=180
var index_left=198

func _ready():
	var titem = load("res://items/TItem.tscn")
	while $Tiles.get_child_count()>0:
		$Tiles.remove_child($Tiles.get_child(0))
	for i in range(0,height):
		var item = titem.instance()
		var index = index_right if direction==DIRECTION.RIGHT else index_left
		item.setInitFrame(index)
		item.position.y=i*10
		$Tiles.add_child(item)
		item = titem.instance()
		item.setInitFrame(index+1)
		item.position.y=i*10
		item.position.x=10
		$Tiles.add_child(item)
# warning-ignore:integer_division
	var size=(height*10)/2
	$Brick.position.y = size
	$Brick.get_shape().set_extents(Vector2(3,size))
	$Zone/Detector.position.y = size
	$Zone/Detector.get_shape().set_extents(Vector2(3,size))
	if direction==DIRECTION.RIGHT:
		$Zone/Detector.position.x = 3
	else:
		$Zone/Detector.position.x = 18

func setDirection(d):
	direction=d

func setHeight(h):
	height=h

func doRotation(Vick):
	Globals.playSound(Globals.snd_rotadoor)
	Vick.state=Vick.st_giratory
	var brick = $Brick
	self.remove_child(brick)
# warning-ignore:unused_variable
	for itera in range(0,9):
		for i in $Tiles.get_children():
			if direction==DIRECTION.RIGHT:
				i.setInitFrame(i.getInitFrame()+2)
				Vick.input_vector.x=1
			else:
				i.setInitFrame(i.getInitFrame()-2)
				Vick.input_vector.x=-1
		$Timer.start(0.1)
		yield($Timer,"timeout")
	if direction==DIRECTION.RIGHT:
		direction=DIRECTION.LEFT
		$Zone/Detector.position.x = 15
	else:
		direction=DIRECTION.RIGHT
		$Zone/Detector.position.x = 5
	Vick.state=Vick.st_walk	
	self.add_child(brick)

func _on_Zone_body_entered(body):
	if body.get_class()=="TVick" && body.state!=body.st_giratory:
		if body.position.y <= self.position.y + height*10:
			doRotation(body)
