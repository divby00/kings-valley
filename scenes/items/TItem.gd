class_name TItem extends Area2D

export (int, 0, 239) var init_frame = 0 setget set_init_frame, get_init_frame


func set_init_frame(r):
	init_frame = r
	$Sprite.frame = init_frame
	update()


func get_init_frame():
	return init_frame
