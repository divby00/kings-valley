tool
class_name TJewel extends Area2D

export (int,0,239) var init_frame=0 setget setInitFrame
export (int,0,6) var cur_frame=0 setget setCurFrame

func _ready():
	if not Engine.editor_hint:
		$Timer.wait_time = 1+(randi() % 14)
		$Timer.start()
	
func setInitFrame(r):
	init_frame=r
	$Sprite.frame=init_frame
	update()

func setCurFrame(r):
	cur_frame=r
	$Sprite.frame=init_frame+cur_frame
	update()

func _on_Timer_timeout():
	$Timer.wait_time = 1+(randi() % 14)
	$Timer.start()
	$Animation.play("brillar")
