tool
extends Area2D

signal jewel_picked(jewel)

export(Texture) var sprite_texture = null

onready var sprite = $Sprite

func _ready():
	sprite.texture = sprite_texture

func _on_Jewel_body_entered(body):
	if body.is_in_group('PlayerGroup'):
		emit_signal("jewel_picked", self)
		call_deferred("queue_free")
