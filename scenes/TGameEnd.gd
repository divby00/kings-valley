class_name TGameEnd extends Node2D

func _ready():
	Globals.playMusic(Globals.MUSICS.ENDING)
	$Path2D/PathFollow2D/vick.self_modulate=Color.black
	$Fader.fadeOut(3)
	yield($Fader,"fade_end")
	$VickAnimator.play("stop")
	yield($VickAnimator,"animation_finished")
	$VickAnimator.play("appear")
	yield($VickAnimator,"animation_finished")
	$VickAnimator.play("walk")
	$PathAnimator.play("move")
	yield($PathAnimator,"animation_finished")
	$VickAnimator.play("stop")
	yield($VickAnimator,"animation_finished")
	$Textos.visible=true
	yield(Globals.getMusicPlayer(),"finished")
	$Fader.fadeIn(3)
	yield($Fader,"fade_end")
	get_tree().change_scene("res://scenes/TMainMenu.tscn")
	
