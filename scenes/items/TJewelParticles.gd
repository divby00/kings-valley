class_name TJewelParticles extends CPUParticles2D


func _ready():
	self.emitting=true


func _on_Timer_timeout():
	queue_free()
