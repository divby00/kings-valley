extends Node2D

var level=1
var last_level=0
onready var stick_joy = $CanvasLayer/StickControls/stick_joy
onready var stick_joy_position = $CanvasLayer/StickControls/stick_joy.position
var stick_joy_point = Vector2.ZERO
var stick_joy_drag = false
var _touch_index :int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/FaderArea.setTransition(1)
	Globals.LIVES=4
	Globals.SCORE=0
	var _ret=$CanvasLayer/TGameOptions.connect("sig_option_selected",self,"on_option_selected")
	showGameOptions(false)
	$CanvasLayer/StickControls.visible = Globals.isTablet()
	doEnterLevel(level,false)
				
func doEnterLevel(plevel,update_last=true):
	if plevel==16:
		doGameEnd()
		return
		
	Globals.stopMusic()
	if update_last: last_level=level
	level=plevel
	var pyramid:TPyramidScreen = load("res://scenes/TPyramidScreen.tscn").instance()
	var _ret=pyramid.setLevel(plevel,last_level)
	_ret=pyramid.connect("sig_update_score",self,"on_update_score")
	_ret=pyramid.connect("sig_next_level",self,"on_next_level")
	_ret=pyramid.connect("sig_show_gameoptions",self,"on_show_gameoptions")
	_ret=pyramid.connect("sig_restart_level",self,"on_restart_level")
	pyramid.rect_position.y = 20
	if $Scene.get_child_count()>0:
		$Scene.get_child(0).queue_free()
	$Scene.add_child(pyramid)
	$CanvasLayer/Scores.visible=true
	$CanvasLayer/FaderArea.fadeOut(1)
	yield($CanvasLayer/FaderArea,"fade_end")
	pyramid.showDoors(true)

func doGameOver():
	var gover = load("res://scenes/TGameOver.tscn").instance()
	gover.rect_position.x = 96
	gover.rect_position.y = 80
	$CanvasLayer.add_child(gover)
	Globals.playMusic(Globals.MUSICS.GAMEOVER,false)
	get_tree().paused=true
	yield(gover,"sig_timeout")
	get_tree().paused=false
	doReturnMenu()
	
func doReturnMenu():
	var _ret=get_tree().change_scene("res://scenes/TMainMenu.tscn")

func doGameEnd():
	var _ret=get_tree().change_scene("res://scenes/TGameEnd.tscn")

func showGameOptions(show:bool):
	if show:
		$CanvasLayer/TGameOptions.set_process(true)
		$CanvasLayer/TGameOptions.doInit()
		$CanvasLayer/TGameOptions.visible=true
		get_tree().paused=true
		Globals.pauseMusic()
	else:
		$CanvasLayer/TGameOptions.set_process(false)
		$CanvasLayer/TGameOptions.visible=false
		get_tree().paused=false

func on_update_score(score, hiscore, rest, pyramid):
	$CanvasLayer/Scores/Score0.setText("SCORE-%06d HI-%06d REST-%02d" % [score,hiscore,rest])
	$CanvasLayer/Scores/Score1.setText("PYRAMID-%02d" % [pyramid])

func on_next_level(currentlevel,nextlevel):
	$CanvasLayer/FaderArea.fadeIn(1)
	yield($CanvasLayer/FaderArea,"fade_end")
	var map:TPyramidMap = load("res://scenes/TPyramidMap.tscn").instance()
	map.from_level=currentlevel
	map.to_level=nextlevel
	var _ret=map.connect("sig_continue_level",self,"on_continue_tolevel")
	$Scene.get_child(0).queue_free()
	$Scene.add_child(map)
	$CanvasLayer/Scores.visible=false
	$CanvasLayer/FaderArea.fadeOut(1)
	yield($CanvasLayer/FaderArea,"fade_end")
	map.run()

func on_continue_tolevel(plevel):
	$CanvasLayer/FaderArea.fadeIn(1)
	yield($CanvasLayer/FaderArea,"fade_end")
	doEnterLevel(plevel)

func on_show_gameoptions():
	showGameOptions(true)
		
func on_option_selected(option:int):
	showGameOptions(false)
	match option:
		0:
			Globals.resumeMusic()
		1:
			$Scene.get_child(0).doDead()
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

func _touch_started(event: InputEventScreenTouch) -> bool:
	return event.pressed and _touch_index == -1

func _touch_ended(event: InputEventScreenTouch) -> bool:
	return not event.pressed and _touch_index == event.index

func _input(event: InputEvent) -> void:
	if !Globals.isTablet():
		return
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return
	if event is InputEventScreenTouch:
		if _touch_started(event):
			if event.position.distance_to(Vector2(stick_joy.position.x+16,stick_joy.position.y+16))<16:
				_touch_index = event.index
				stick_joy_point=event.position
				stick_joy_drag=true
			else:
				_touch_index = -1
				stick_joy_drag=false
				stick_joy.position = stick_joy_position
		elif _touch_ended(event):
			_touch_index = -1
			stick_joy_drag=false
			stick_joy.position = stick_joy_position
			Input.action_release("ui_left")
			Input.action_release("ui_right")
			Input.action_release("ui_up")
			Input.action_release("ui_down")
			
	elif event is InputEventScreenDrag:
		if stick_joy_drag:
						
			stick_joy.position = stick_joy_position + (event.position - stick_joy_point)

			if stick_joy.position.x < stick_joy_position.x-8: 
				stick_joy.position.x = stick_joy_position.x-8
			elif stick_joy.position.x > stick_joy_position.x+8: 
				stick_joy.position.x = stick_joy_position.x+8
		
			if stick_joy.position.y < stick_joy_position.y-8: 
				stick_joy.position.y = stick_joy_position.y-8
			elif stick_joy.position.y > stick_joy_position.y+8: 
				stick_joy.position.y = stick_joy_position.y+8

			Input.action_release("ui_left")
			Input.action_release("ui_right")
			Input.action_release("ui_up")
			Input.action_release("ui_down")

			var offset:Vector2 = stick_joy.position-stick_joy_position
				
			if offset.x<0:
				Input.action_press("ui_left")
			elif offset.x>0:
				Input.action_press("ui_right")
		
			if offset.y < 0:
				Input.action_press("ui_up")
			elif offset.y > 0:
				Input.action_press("ui_down")
