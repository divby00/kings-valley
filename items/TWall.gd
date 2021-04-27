class_name TWall extends Area2D

var tile:int
var pyramid
var active:bool=false
var x0:int
var y0:int
var y1:int
var index:int

func doInit(pyr,px:int,py:int,py1:int,px1:int):
	pyramid=pyr
	self.position.x=px*10
	self.position.y=py*10
	$Activator.position.y = (py1-py)*10+5
	$Activator.position.x = (px1-px)*10+5
	tile=pyramid.getBufferValue(pyramid.frontBuffer,px,py)
	active=false
	x0=px
	y0=py
	y1=py1
	index=y0

func _on_TWall_body_entered(body):
	if !active && body.get_class()=="TVick":
		active=true
		$Timer.start(1)
		
func _on_Timer_timeout():
	if index<y1:
		index+=1
		pyramid.setBufferValue(pyramid.frontBuffer,x0,index,tile)
		pyramid.drawFrontTile(x0,index,tile-1)
		$Timer.start(1)