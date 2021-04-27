extends ColorRect

func _ready():
	$FaderArea.fadeOut(2)
	yield($FaderArea,"fade_end")
	if Globals.isTablet():
		$press.setText("TOUCH THE SCREEN")
	$press.visible=true
	
func _process(_delta):
	if not $FaderArea.isFadding():
		if Input.is_action_just_released("ui_select"):
			$FaderArea.fadeIn(2)
			yield($FaderArea,"fade_end")
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/TKonami.tscn")
		
func _on_TouchScreenButton_released():
	Input.action_release("ui_select")
