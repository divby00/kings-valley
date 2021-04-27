class_name TJoystick extends Node2D

signal sig_on_change(position)

export (bool) var enabled = true

onready var stick_joy=$stick_joy
onready var stick_joy_position:Vector2=$stick_joy.position

var stick_joy_point = Vector2.ZERO
var stick_joy_drag = false
var _touch_index:int = -1

func _touch_started(event: InputEventScreenTouch) -> bool:
	return event.pressed and _touch_index == -1

func _touch_ended(event: InputEventScreenTouch) -> bool:
	return not event.pressed and _touch_index == event.index

func _input(event: InputEvent) -> void:
	if not (enabled and (event is InputEventScreenTouch or event is InputEventScreenDrag)):
		return
	if event is InputEventScreenTouch:
		if _touch_started(event):
			if event.position.distance_to(stick_joy.global_position)<16:
				_touch_index = event.index
				stick_joy_point=event.position
				stick_joy_drag=true
			else:
				_touch_index = -1
				stick_joy_drag=false
				stick_joy.position = stick_joy_position
				emit_signal("sig_on_change",Vector2.ZERO)
		elif _touch_ended(event):
			_touch_index = -1
			stick_joy_drag=false
			stick_joy.position = stick_joy_position
			emit_signal("sig_on_change",Vector2.ZERO)
			
	elif event is InputEventScreenDrag:
		if stick_joy_drag:
						
			stick_joy.position = stick_joy_position + (event.position - stick_joy_point)

			if stick_joy.position.x < stick_joy_position.x-8: 
				stick_joy.position.x = stick_joy_position.x-8
			elif stick_joy.position.x > stick_joy_position.x+8: 
				stick_joy.position.x = stick_joy_position.x+8
		
			if stick_joy.position.y < stick_joy_position.y-8: 
				stick_joy.position.y = stick_joy_position.y-8
			elif stick_joy.position.y > stick_joy_position.y+8: 
				stick_joy.position.y = stick_joy_position.y+8

			var offset:Vector2 = (stick_joy.position-stick_joy_position)/8

			emit_signal("sig_on_change",offset)
