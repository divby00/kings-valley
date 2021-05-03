class_name TGameScene extends Node2D

onready var fader = $CanvasLayer/FaderArea
onready var scores = $CanvasLayer/Scores
onready var score_0 = $CanvasLayer/Scores/Score0
onready var score_1 = $CanvasLayer/Scores/Score1
onready var game_options = $CanvasLayer/TGameOptions
onready var game_cheats = $CanvasLayer/TEnterCheat
onready var stick_controls = $CanvasLayer/StickControls
onready var joystick = $CanvasLayer/StickControls/TJoystick
onready var scene_node = $Scene
onready var canvas_layer = $CanvasLayer

var level = 1
var last_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	fader.set_transition(1)
	Globals.LIVES = 4
	Globals.SCORE = 0
	Globals.connect_signal(game_options, "sig_option_selected", self, "on_option_selected")
	Globals.connect_signal(game_cheats, "sig_cheat_entered", self, "on_cheat_entered")
	show_game_options(false)
	stick_controls.visible = Globals.is_android()
	joystick.enabled = Globals.is_android()
	do_enter_level(level, false)


func do_enter_level(plevel, update_last = true):
	if plevel == 16:
		do_game_end()
		return

	Globals.stop_music()
	if update_last:
		last_level = level
	level = plevel
	var pyramid: TPyramidScreen = Globals.load_scene(Globals.SCENES.PYRAMID).instance()
	var _ret = pyramid.set_level(plevel, last_level)
	Globals.connect_signal(pyramid, "sig_update_score", self, "on_update_score")
	Globals.connect_signal(pyramid, "sig_next_level", self, "on_next_level")
	Globals.connect_signal(pyramid, "sig_show_gameoptions", self, "on_show_gameoptions")
	Globals.connect_signal(pyramid, "sig_restart_level", self, "on_restart_level")
	pyramid.rect_position.y = 20
	if scene_node.get_child_count() > 0:
		scene_node.get_child(0).queue_free()
	scene_node.add_child(pyramid)
	scores.visible = true
	fader.fade_out(1)
	yield(fader, "fade_end")
	pyramid.show_doors(true)


func do_game_over():
	var gover = Globals.load_scene(Globals.SCENES.GAMEOVER).instance()
	gover.rect_position.x = 96
	gover.rect_position.y = 80
	canvas_layer.add_child(gover)
	Globals.play_music(Globals.MUSICS.GAMEOVER, false)
	get_tree().paused = true
	yield(gover, "sig_timeout")
	get_tree().paused = false
	do_return_menu()


func do_return_menu():
	Globals.set_scene(Globals.SCENES.MAINMENU)


func do_game_end():
	Globals.set_scene(Globals.SCENES.ENDGAME)


func show_game_options(show: bool):
	if show:
		game_options.set_process(true)
		game_options.do_init()
		game_options.visible = true
		get_tree().paused = true
		Globals.pause_music()
	else:
		game_options.set_process(false)
		game_options.visible = false
		get_tree().paused = false

func show_game_cheats(show:bool):
	if show:
		game_cheats.set_process(true)
		game_cheats.do_init()
		game_cheats.visible = true
		get_tree().paused = true
		Globals.pause_music()
	else:
		game_cheats.set_process(false)
		game_cheats.visible = false
		get_tree().paused = false

func on_update_score(score, hiscore, rest, pyramid):
	score_0.set_text("SCORE-%06d HI-%06d REST-%02d" % [score, hiscore, rest])
	score_1.set_text("PYRAMID-%02d" % [pyramid])


func on_next_level(currentlevel, nextlevel):
	fader.fade_in(1)
	yield(fader, "fade_end")
	var map: TPyramidMap = Globals.load_scene(Globals.SCENES.PYRAMIDMAP).instance()
	map.from_level = currentlevel
	map.to_level = nextlevel
	Globals.connect_signal(map, "sig_continue_level", self, "on_continue_tolevel")
	scene_node.get_child(0).queue_free()
	scene_node.add_child(map)
	scores.visible = false
	fader.fade_out(1)
	yield(fader, "fade_end")
	map.run()


func on_continue_tolevel(plevel):
	fader.fade_in(1)
	yield(fader, "fade_end")
	do_enter_level(plevel)


func on_show_gameoptions():
	show_game_options(true)


func on_option_selected(option: int):
	show_game_options(false)
	match option:
		TGameOptions.OPTION.CONTINUE:
			Globals.resume_music()
		TGameOptions.OPTION.RESTART:
			scene_node.get_child(0).do_dead()
		TGameOptions.OPTION.CHEAT:
			show_game_cheats(true)
		TGameOptions.OPTION.EXIT:
			do_return_menu()

func on_cheat_entered(cheat):
	show_game_cheats(false)
	scene_node.get_child(0).do_cheat(cheat)

func on_restart_level():
	if Globals.LIVES >= 0:
		do_enter_level(level, false)
	else:
		do_game_over()


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
