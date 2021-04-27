class_name TJewel extends Area2D

export (int,0,239) var init_frame=0 setget setInitFrame
export (int,0,6) var cur_frame=0 setget setCurFrame

onready var timer = $Timer
onready var animation = $Animation

func _ready():
	if not Engine.editor_hint:
		timer.wait_time = 1+(randi() % 14)
		timer.start()
	
func setInitFrame(r):
	init_frame=r
	$Sprite.frame=init_frame
	update()

func setCurFrame(r):
	cur_frame=r
	$Sprite.frame=init_frame+cur_frame
	update()

func _on_Timer_timeout():
	timer.wait_time = 1+(randi() % 14)
	timer.start()
	animation.play("brillar")
