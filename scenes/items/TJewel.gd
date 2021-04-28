class_name TJewel extends Area2D

export (int, 0, 239) var init_frame = 0 setget set_init_frame
export (int, 0, 6) var current_frame = 0 setget set_current_frame

onready var timer = $Timer
onready var animation = $Animation


func _ready():
	if not Engine.editor_hint:
		timer.wait_time = 1 + (randi() % 14)
		timer.start()


func set_init_frame(r):
	init_frame = r
	$Sprite.frame = init_frame
	update()


func set_current_frame(r):
	current_frame = r
	$Sprite.frame = init_frame + current_frame
	update()


func _on_Timer_timeout():
	timer.wait_time = 1 + (randi() % 14)
	timer.start()
	animation.play("brillar")
