tool
class_name FaderArea extends Sprite

export (Color, RGB) var color setget set_color
export (float, 0.0, 1.0) var transition = 0.5 setget set_transition

signal fade_end
signal fade_start

onready var tween = $Tween


func set_transition(trans):
	transition = trans
	material.set_shader_param("cut", trans)
	update()


func set_color(col):
	color = col
	material.set_shader_param("acolor", color)
	update()


func fade_in(secs: float):
	emit_signal("fade_start")
	self.flip_h = true
	tween.stop_all()
	tween.interpolate_property(self, "transition", 0.0, 1.0, secs)
	tween.start()


func fade_out(secs: float):
	emit_signal("fade_start")
	self.flip_h = false
	tween.stop_all()
	tween.interpolate_property(self, "transition", 1.0, 0.0, secs)
	tween.start()


func is_fading() -> bool:
	return tween.is_active()


func _on_Tween_tween_all_completed():
	emit_signal("fade_end")
