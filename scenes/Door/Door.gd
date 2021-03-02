extends Area2D

signal prepare_player(position)
# warning-ignore:unused_signal
signal hide_doors

enum Status {
	STARTING,
	EXITING,
	OPENING,
	OPENED,
	CLOSING,
	CLOSED
}

export(String) var door_type = "entrada"

onready var door_trigger = $DoorTrigger
onready var animation_player = $AnimationPlayer
onready var status = Status.CLOSED setget set_status
onready var visibility = true

func _ready():
	Utils.connect_signal(door_trigger, "trigger_pressed", self, "on_trigger_pressed")

func start():
	self.status = Status.STARTING

func close():
	self.status = Status.CLOSED

func create_player():
	emit_signal("prepare_player", Vector2(self.global_position.x + 16, self.global_position.y - 16))

func set_status(value):
	status = value
	if value == Status.STARTING:
		animation_player.play("start")
	if value == Status.OPENING:
		animation_player.play("open")
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'open':
		self.status = Status.OPENED

func on_trigger_pressed():
	self.status = Status.OPENING
