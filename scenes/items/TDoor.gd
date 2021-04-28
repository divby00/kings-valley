class_name TDoor extends Node2D

signal door_opened
signal door_closed
signal door_exiting

enum TYPE { IN = 0, OUT = 1, BOTH = 2 }

onready var animator = $Animator
onready var vick_position = $VickPosition
onready var exit_door_left = $ExitDoorLeft
onready var exit_door_right = $ExitDoorRight
onready var push_button = $PushButton

var door_type = TYPE.IN
var ready_to_exit = false
var vick = null


func _ready():
	set_close(true)


func get_vick_position() -> Vector2:
	return vick_position.position


func set_close(front: bool):
	exit_door_left.position.x = 15
	exit_door_right.position.x = 25
	exit_door_left.z_index = 10 if front else 0
	exit_door_right.z_index = 10 if front else 0


func open_door(front: bool):
	exit_door_left.z_index = 10 if front else 0
	exit_door_right.z_index = 10 if front else 0
	animator.play("open")
	Globals.play_sound(Globals.snd_door)
	yield(animator, "animation_finished")
	emit_signal("door_opened")
	exit_door_left.z_index = 0
	exit_door_right.z_index = 0


func close_door(front: bool):
	exit_door_left.z_index = 10 if front else 0
	exit_door_right.z_index = 10 if front else 0
	animator.play("close")
	Globals.play_sound(Globals.snd_door)
	yield(animator, "animation_finished")
	emit_signal("door_closed")


func _on_push_button_body_entered(body):
	if self.visible and body == vick and ready_to_exit and push_button.init_frame == 202:
		push_button.init_frame = 201
		open_door(false)


func _on_exitzone_body_entered(body):
	if self.visible and body == vick and ready_to_exit and push_button.init_frame == 201:
		vick.position = self.position + get_vick_position()
		vick.state = vick.st_goingout
		vick.input_vector.x = 1
		emit_signal("door_exiting")
		close_door(true)
		yield(animator, "animation_finished")
		vick.visible = false
		if door_type in [TYPE.OUT, TYPE.BOTH]:
			vick.go_next_level()
		else:
			vick.do_previous_level()
