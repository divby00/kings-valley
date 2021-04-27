class_name TKonami extends ColorRect

onready var animator = $Animator

# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("slide_up")

func _process(_delta):
	if Input.is_action_just_released("ui_select"):
		Globals.set_scene(Globals.SCENES.MAINMENU)

func _on_TouchScreenButton_released():
	Input.action_release("ui_select")
