extends ColorRect

signal sig_timeout()

onready var timer = $Timer

func _ready():
	timer.start(5)
	yield(timer,"timeout")
	emit_signal("sig_timeout")
	
