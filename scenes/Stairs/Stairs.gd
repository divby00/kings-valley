extends Area2D

signal player_on_stairs(stair)

export(String) var direction

func _on_Stair_body_entered(body):
	if body.is_in_group('PlayerGroup'):
		emit_signal("player_on_stairs", self)
