class_name TGameScene extends Node2D

onready var fader = $CanvasLayer/FaderArea
onready var scores = $CanvasLayer/Scores
onready var score_0 = $CanvasLayer/Scores/Score0
onready var score_1 = $CanvasLayer/Scores/Score1
onready var game_options = $CanvasLayer/TGameOptions
onready var stick_controls = $CanvasLayer/StickControls
onready var joystick = $CanvasLayer/StickControls/TJoystick
onready var scene_node = $Scene
onready var canvas_layer = $CanvasLayer

var level=16
var last_level=0

# Called when the node enters the scene tree for the first time.
func _ready():
	fader.set_transition(1)
	Globals.LIVES=4
	Globals.SCORE=0
	Globals.connect_signal(game_options,"sig_option_selected",self,"on_option_selected")
	showGameOptions(false)
	stick_controls.visible = Globals.is_android()
	joystick.enabled=Globals.is_android()
	doEnterLevel(level,false)
				
func doEnterLevel(plevel,update_last=true):
	if plevel==16:
		doGameEnd()
		return
		
	Globals.stop_music()
	if update_last: last_level=level
	level=plevel
	var pyramid:TPyramidScreen = Globals.load_scene(Globals.SCENES.PYRAMID).instance()
	var _ret=pyramid.setLevel(plevel,last_level)
	Globals.connect_signal(pyramid,"sig_update_score",self,"on_update_score")
	Globals.connect_signal(pyramid,"sig_next_level",self,"on_next_level")
	Globals.connect_signal(pyramid,"sig_show_gameoptions",self,"on_show_gameoptions")
	Globals.connect_signal(pyramid,"sig_restart_level",self,"on_restart_level")
	pyramid.rect_position.y = 20
	if scene_node.get_child_count()>0:
		scene_node.get_child(0).queue_free()
	scene_node.add_child(pyramid)
	scores.visible=true
	fader.fade_out(1)
	yield(fader,"fade_end")
	pyramid.showDoors(true)

func doGameOver():
	var gover = Globals.load_scene(Globals.SCENES.GAMEOVER).instance()
	gover.rect_position.x = 96
	gover.rect_position.y = 80
	canvas_layer.add_child(gover)
	Globals.play_music(Globals.MUSICS.GAMEOVER,false)
	get_tree().paused=true
	yield(gover,"sig_timeout")
	get_tree().paused=false
	doReturnMenu()
	
func doReturnMenu():
	Globals.set_scene(Globals.SCENES.MAINMENU)

func doGameEnd():
	Globals.set_scene(Globals.SCENES.ENDGAME)

func showGameOptions(show:bool):
	if show:
		game_options.set_process(true)
		game_options.do_init()
		game_options.visible=true
		get_tree().paused=true
		Globals.pause_music()
	else:
		game_options.set_process(false)
		game_options.visible=false
		get_tree().paused=false

func on_update_score(score, hiscore, rest, pyramid):
	score_0.set_text("SCORE-%06d HI-%06d REST-%02d" % [score,hiscore,rest])
	score_1.set_text("PYRAMID-%02d" % [pyramid])

func on_next_level(currentlevel,nextlevel):
	fader.fade_in(1)
	yield(fader,"fade_end")
	var map:TPyramidMap = Globals.load_scene(Globals.SCENES.PYRAMIDMAP).instance()
	map.from_level=currentlevel
	map.to_level=nextlevel
	Globals.connect_signal(map,"sig_continue_level",self,"on_continue_tolevel")
	scene_node.get_child(0).queue_free()
	scene_node.add_child(map)
	scores.visible=false
	fader.fade_out(1)
	yield(fader,"fade_end")
	map.run()

func on_continue_tolevel(plevel):
	fader.fade_in(1)
	yield(fader,"fade_end")
	doEnterLevel(plevel)

func on_show_gameoptions():
	showGameOptions(true)
		
func on_option_selected(option:int):
	showGameOptions(false)
	match option:
		0:
			Globals.resume_music()
		1:
			scene_node.get_child(0).doDead()
		2:
			doReturnMenu()
		
func on_restart_level():
	if Globals.LIVES>=0:
		doEnterLevel(level,false)
	else:
		doGameOver()

func _on_stick_action_pressed():
	Input.action_press("ui_select")

func _on_stick_home_pressed():
	Input.action_press("ui_home")

func _on_TJoystick_sig_on_change(position):
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("ui_left")
	Input.action_release("ui_right")

	if position.x < -0.7:
		Input.action_press("ui_left")
	elif position.x > 0.7:
		Input.action_press("ui_right")

	if position.y < -0.7:
		Input.action_press("ui_up")
	elif position.y > 0.7:
		Input.action_press("ui_down")
