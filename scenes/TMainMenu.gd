extends ColorRect

enum STATE {OPTIONS,CREDITS,OUT}
var state = STATE.OPTIONS
var option_menu=0
var option_position
var scroll_y

func _ready():
	Globals.playMusic(Globals.MUSICS.MENU)
	option_position = [$MenuOptions/start_game.position.y, $MenuOptions/sound_sets.position.y, $MenuOptions/credits.position.y, $MenuOptions/exit_game.position.y]
	scroll_y= $Scroll/Credits.rect_position.y
	update_soundset()
		
func _process(_delta):	
	match state:
		STATE.CREDITS:
			if Input.is_action_just_pressed("ui_select"):
				_on_ScrollAnimator_animation_finished("")
				
		STATE.OPTIONS:	
			if Input.is_action_just_pressed("ui_down") and option_menu<3:
				option_menu+=1
				$MenuOptions/selector.position.y = option_position[option_menu]
			elif Input.is_action_just_pressed("ui_up") and option_menu>0:
				option_menu-=1
				$MenuOptions/selector.position.y = option_position[option_menu]
			elif Input.is_action_just_pressed("ui_select"):
				match option_menu:
					0:
						state=STATE.OUT
						Globals.playMusic(Globals.MUSICS.GETREADY)
						self.set_process(false)
						yield(Globals.getMusicPlayer(),"finished")
						get_tree().change_scene("res://scenes/TGameScene.tscn")
					1:
						Globals.loadSounds(!Globals.soundset_new)
						update_soundset()
						Globals.playSound(Globals.snd_fall)
					2:
						state=STATE.CREDITS
						$MenuOptions.visible=false
						$Scroll.visible=true
						$Scroll/Credits/ScrollAnimator.play("scroll_up")
					3:
						get_tree().quit()
	
func update_soundset():
	if Globals.soundset_new:
		$MenuOptions/sound_sets.setText("MODERN SOUNDSET")
	else:
		$MenuOptions/sound_sets.setText("CLASSIC SOUNDSET")


func _on_ScrollAnimator_animation_finished(anim_name):
	$MenuOptions.visible=true
	$Scroll.visible=false
	$Scroll/Credits/ScrollAnimator.stop(true)
	$Scroll/Credits.rect_position.y=scroll_y
	state=STATE.OPTIONS

func setOption(opt) -> bool:
	if state!=STATE.OPTIONS:
		return false

	if (option_menu!=opt):
		option_menu=opt
		$MenuOptions/selector.position.y = option_position[option_menu]
		return false
	return true

func _on_BT_start_game_pressed():
	if setOption(0):
		Input.action_press("ui_select")

func _on_BT_sound_set_pressed():
	if setOption(1):
		Input.action_press("ui_select")

func _on_BT_credits_pressed():
	if setOption(2):
		Input.action_press("ui_select")

func _on_BT_exitgame_pressed():
	if setOption(3):
		Input.action_press("ui_select")

func _on_BT_endcredits_pressed():
	if state==STATE.CREDITS:
		Input.action_press("ui_select")
