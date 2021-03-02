extends Area2D

signal trigger_pressed

enum Status {
	TRIGGER_OFF,
	TRIGGER_ON,
}

onready var sprite = $Sprite
onready var status = Status.TRIGGER_OFF setget set_status

func set_status(value):
	status = clamp(value, Status.TRIGGER_OFF, Status.TRIGGER_ON)
	sprite.frame = status

func _on_DoorTrigger_body_entered(body):
	if body.is_in_group('PlayerGroup') and status == Status.TRIGGER_OFF:
		self.status = Status.TRIGGER_ON
		emit_signal('trigger_pressed')
