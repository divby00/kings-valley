tool
class_name FaderArea extends Sprite

export (float,0.0,1.0) var transition=0.5 setget setTransition
export (Color,RGB) var color setget setColor 

signal fade_start
signal fade_end

onready var tween = $Tween

func setTransition(trans):
	transition = trans
	material.set_shader_param("cut",trans)
	update()
	
func setColor(col):
	color = col;
	material.set_shader_param("acolor",color)
	update()
	
func fadeIn(secs:float):
	emit_signal("fade_start")
	self.flip_h=true
	tween.stop_all()
	tween.interpolate_property(self,"transition",0.0,1.0,secs)
	tween.start()

func fadeOut(secs:float):
	emit_signal("fade_start")
	self.flip_h=false
	tween.stop_all()
	tween.interpolate_property(self,"transition",1.0,0.0,secs)
	tween.start()
	
func isFadding() -> bool:
	return tween.is_active()

func _on_Tween_tween_all_completed():
	emit_signal("fade_end")
	
