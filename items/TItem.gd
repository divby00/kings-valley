class_name TItem extends Area2D

export (int,0,239) var init_frame=0 setget setInitFrame,getInitFrame
	
func setInitFrame(r):
	init_frame=r
	$Sprite.frame=init_frame
	update()

func getInitFrame():
	return init_frame
