class_name TDoor extends Node2D

signal door_opened
signal door_closed
signal door_exiting

enum TYPE {IN=0,OUT=1,BOTH=2}

onready var vick_position = $VickPosition
onready var exitdoor_left = $exitdoor_left
onready var exitdoor_right = $exitdoor_right
onready var animator = $Animator
onready var pushbutton = $pushbutton

var door_type=TYPE.IN
var ready_to_exit=false
var Vick = null

func _ready():
	setClose(true)

func vickPosition() -> Vector2:
	return vick_position.position

func setClose(front:bool):
	exitdoor_left.position.x = 15
	exitdoor_right.position.x = 25
	exitdoor_left.z_index=10 if front else 0
	exitdoor_right.z_index=10 if front else 0
	
func openDoor(front:bool):
	exitdoor_left.z_index=10 if front else 0
	exitdoor_right.z_index=10 if front else 0
	animator.play("open")
	Globals.playSound(Globals.snd_door)
	yield(animator,"animation_finished")
	emit_signal("door_opened")
	exitdoor_left.z_index=0
	exitdoor_right.z_index=0

func closeDoor(front:bool):
	exitdoor_left.z_index=10 if front else 0
	exitdoor_right.z_index=10 if front else 0
	animator.play("close")
	Globals.playSound(Globals.snd_door)
	yield(animator,"animation_finished")
	emit_signal("door_closed")

func _on_pushbutton_body_entered(body):
	if self.visible and body==Vick and ready_to_exit and pushbutton.init_frame==202:
		pushbutton.init_frame=201
		openDoor(false)

func _on_exitzone_body_entered(body):
	if self.visible and body==Vick and ready_to_exit and pushbutton.init_frame==201:
		Vick.position = self.position + vickPosition()
		Vick.state=Vick.st_goingout
		Vick.input_vector.x=1
		emit_signal("door_exiting")
		closeDoor(true)
		yield(animator,"animation_finished")
		Vick.visible=false
		if door_type in [TYPE.OUT,TYPE.BOTH]:
			Vick.goNextLevel()
		else:
			Vick.goPrevLevel()
