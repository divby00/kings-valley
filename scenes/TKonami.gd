extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animator.play("slide_up")

func _process(delta):
	if Input.is_action_just_released("ui_select"):
		get_tree().change_scene("res://scenes/TMainMenu.tscn")

func _on_TouchScreenButton_released():
	Input.action_release("ui_select")
