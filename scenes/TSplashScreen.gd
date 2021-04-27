extends ColorRect

onready var fader = $FaderArea
onready var txtpress = $press

func _ready():
	fader.fadeOut(2)
	yield(fader,"fade_end")
	if Globals.isTablet():
		txtpress.setText("TOUCH THE SCREEN")
	txtpress.visible=true
	
func _process(_delta):
	if not fader.isFadding():
		if Input.is_action_just_released("ui_select"):
			fader.fadeIn(2)
			yield(fader,"fade_end")
			Globals.set_scene(Globals.SCENES.KONAMI)			
		
func _on_TouchScreenButton_released():
	Input.action_release("ui_select")
