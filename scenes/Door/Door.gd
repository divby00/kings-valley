extends Area2D

signal create_player(position)

enum Status {
	LEVEL_IN,
	LEVEL_OUT,
	OPENING,
	OPENED,
	CLOSED
}

export(String) var door_type = "entrada"

onready var door_trigger = $DoorTrigger
onready var animation_player = $AnimationPlayer
onready var status = Status.CLOSED setget set_status
onready var visibility = true

func init():
	self.status = Status.LEVEL_IN

func create_player():
	emit_signal("create_player", Vector2(self.global_position.x + 16, self.global_position.y - 16))

func set_status(value):
	status = value
	if value == Status.LEVEL_IN:
		animation_player.play("open")
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'open':
		if status == Status.LEVEL_IN:
			animation_player.play('player_in')
	
	if anim_name == 'player_in':
		animation_player.play("close")
