class_name TGameOptions extends ColorRect

signal sig_option_selected(option)

onready var selector = $selector
onready var option_pos=[$continue.position.y,$restart.position.y,$exit.position.y]

var option=0

func _ready():
	do_init()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		if option<2:
			option+=1
			selector.position.y = option_pos[option]
	elif Input.is_action_just_pressed("ui_up"):
		if option>0:
			option-=1
			selector.position.y = option_pos[option]
	elif Input.is_action_just_pressed("ui_select"):
		emit_signal("sig_option_selected",option)

func do_init():
	option=0
	selector.position.y = option_pos[option]

func set_option(opt) -> bool:
	if (option!=opt):
		option=opt
		selector.position.y = option_pos[option]
		return false
	return true

func _on_BT_continue_pressed():
	if set_option(0):
		Input.action_press("ui_select")

func _on_BT_restart_pressed():
	if set_option(1):
		Input.action_press("ui_select")

func _on_BT_exit_pressed():
	if set_option(2):
		Input.action_press("ui_select")
