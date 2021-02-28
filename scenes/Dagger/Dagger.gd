extends Area2D

signal dagger_picked(dagger)


func _on_Dagger_body_entered(body):
	if body.is_in_group('PlayerGroup') and Stats.item == Stats.Items.None:
		emit_signal("dagger_picked", self)
		call_deferred("queue_free")
