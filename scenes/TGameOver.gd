extends ColorRect

signal sig_timeout()

func _ready():
	$Timer.start(5)
	yield($Timer,"timeout")
	emit_signal("sig_timeout")
	
