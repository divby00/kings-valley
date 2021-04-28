class_name TGameEnd extends Node2D

onready var vick = $Path2D/PathFollow2D/vick
onready var vick_animator = $VickAnimator
onready var path_animator = $PathAnimator
onready var fader = $Fader
onready var texts = $Textos


func _ready():
	Globals.play_music(Globals.MUSICS.ENDING)
	vick.self_modulate = Color.black
	fader.fade_out(3)
	yield(fader, "fade_end")
	vick_animator.play("stop")
	yield(vick_animator, "animation_finished")
	vick_animator.play("appear")
	yield(vick_animator, "animation_finished")
	vick_animator.play("walk")
	path_animator.play("move")
	yield(path_animator, "animation_finished")
	vick_animator.play("stop")
	yield(vick_animator, "animation_finished")
	texts.visible = true
	yield(Globals.get_music_player(), "finished")
	fader.fade_in(3)
	yield(fader, "fade_end")
	Globals.set_scene(Globals.SCENES.MAINMENU)
