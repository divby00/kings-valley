class_name TMainMenu extends ColorRect

enum STATE { OPTIONS, CREDITS, OUT }

onready var selector = $MenuOptions/selector
onready var menu_options = $MenuOptions
onready var scroll = $Scroll
onready var scroll_animator = $Scroll/Credits/ScrollAnimator
onready var start_game = $MenuOptions/start_game
onready var sound_sets = $MenuOptions/sound_sets
onready var credits = $MenuOptions/credits
onready var exit_game = $MenuOptions/exit_game
onready var scredits = $Scroll/Credits
onready var scroll_y = scredits.rect_position.y
onready var option_position = [
	start_game.position.y, sound_sets.position.y, credits.position.y, exit_game.position.y
]

var state = STATE.OPTIONS
var option_menu = 0


func _ready():
	Globals.play_music(Globals.MUSICS.MENU)
	update_soundset()


func _process(_delta):
	match state:
		STATE.CREDITS:
			if Input.is_action_just_pressed("ui_select"):
				_on_ScrollAnimator_animation_finished("")

		STATE.OPTIONS:
			if Input.is_action_just_pressed("ui_down") and option_menu < 3:
				option_menu += 1
				selector.position.y = option_position[option_menu]
			elif Input.is_action_just_pressed("ui_up") and option_menu > 0:
				option_menu -= 1
				selector.position.y = option_position[option_menu]
			elif Input.is_action_just_pressed("ui_select"):
				match option_menu:
					0:
						state = STATE.OUT
						Globals.play_music(Globals.MUSICS.GETREADY)
						self.set_process(false)
						yield(Globals.get_music_player(), "finished")
						Globals.set_scene(Globals.SCENES.GAME)
					1:
						Globals.load_sounds(! Globals.soundset_new)
						update_soundset()
						Globals.play_sound(Globals.snd_fall)
					2:
						state = STATE.CREDITS
						menu_options.visible = false
						scroll.visible = true
						scroll_animator.play("scroll_up")
					3:
						get_tree().quit()


func update_soundset():
	if Globals.soundset_new:
		sound_sets.set_text("MODERN SOUNDSET")
	else:
		sound_sets.set_text("CLASSIC SOUNDSET")


func _on_ScrollAnimator_animation_finished(_anim_name):
	menu_options.visible = true
	scroll.visible = false
	scroll_animator.stop(true)
	scredits.rect_position.y = scroll_y
	state = STATE.OPTIONS


func set_option(opt) -> bool:
	if state != STATE.OPTIONS:
		return false

	if option_menu != opt:
		option_menu = opt
		selector.position.y = option_position[option_menu]
		return false
	return true


func _on_BT_start_game_pressed():
	if set_option(0):
		Input.action_press("ui_select")


func _on_BT_sound_set_pressed():
	if set_option(1):
		Input.action_press("ui_select")


func _on_BT_credits_pressed():
	if set_option(2):
		Input.action_press("ui_select")


func _on_BT_exitgame_pressed():
	if set_option(3):
		Input.action_press("ui_select")


func _on_BT_endcredits_pressed():
	if state == STATE.CREDITS:
		Input.action_press("ui_select")
