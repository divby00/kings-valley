class_name TGameOptions extends ColorRect


onready var selector = $selector

signal sig_option_selected(option)

var option=0
var option_pos=[]

func _ready():
	option_pos=[$continue.position.y,$restart.position.y,$exit.position.y]
	doInit()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		if option<2:
			option+=1
			$selector.position.y = option_pos[option]
	elif Input.is_action_just_pressed("ui_up"):
		if option>0:
			option-=1
			$selector.position.y = option_pos[option]
	elif Input.is_action_just_pressed("ui_select"):
		emit_signal("sig_option_selected",option)

func doInit():
	option=0
	$selector.position.y = option_pos[option]

func setOption(opt) -> bool:
	if (option!=opt):
		option=opt
		$selector.position.y = option_pos[option]
		return false
	return true

func _on_BT_continue_pressed():
	if setOption(0):
		Input.action_press("ui_select")

func _on_BT_restart_pressed():
	if setOption(1):
		Input.action_press("ui_select")

func _on_BT_exit_pressed():
	if setOption(2):
		Input.action_press("ui_select")
