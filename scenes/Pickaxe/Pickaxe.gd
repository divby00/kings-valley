extends Area2D

signal pickaxe_picked(pickaxe)

func _on_Pickaxe_body_entered(body):
	if body.is_in_group('PlayerGroup') and Stats.item == Stats.Items.None:
		emit_signal("pickaxe_picked", self)
		call_deferred("queue_free")
