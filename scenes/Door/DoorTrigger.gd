extends Area2D

signal trigger_pressed(door)

enum Status {
	TRIGGER_OFF,
	TRIGGER_ON,
}

onready var status = Status.TRIGGER_OFF

func _on_DoorTrigger_body_entered(_body):
	if _body.is_in_group('PlayerGroup') and status == Status.TRIGGER_OFF:
		status = Status.TRIGGER_ON
		emit_signal('trigger_pressed', self)
