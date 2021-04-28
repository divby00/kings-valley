extends Node2D

enum MUSICS {
	MENU = 0,
	GETREADY = 1,
	PYRAMIDMAP = 2,
	GAMEOVER = 3,
	ENDING = 4,
	MUSIC1 = 5,
	MUSIC2 = 6,
	MUSIC3 = 7,
	MUSIC4 = 8,
	MUSIC5 = 9
}
enum SCENES { KONAMI, MAINMENU, GAME, GAMEOVER, PYRAMIDMAP, PYRAMID, ENDGAME }

onready var com_sound = $ComSound
onready var com_music = $ComMusic
onready var space_state = get_world_2d().direct_space_state

var tablet_mode = (OS.get_name() == "Android")
var soundset_new: bool = false

# ---------------------------------------------
# Constantes para identificar tipo de elementos
# ---------------------------------------------
const It_none = 0  # Nada
const It_brick = 76  # Asc("L") Ladrillo
const It_giratory = 71  # Asc("G") Puerta Giratoria
const It_rgiratory = 62  # Asc(">") Puerta Giratoria a Derecha
const It_lgiratory = 60  # Asc("<") Puerta Giratoria a Izquierda
const It_dagger = 68  # Asc("D") Daga
const It_picker = 80  # Asc("P") Pico
const It_jewel = 74  # Asc("J") Joya
const It_door = 84  # Asc("T") Puerta Entrada/Salida
const It_wall = 85  # Asc("U") Muro que aparece y crece
const It_mummy = 77  # Asc("M") Posicion de Momia
const It_stairs = 69  # Asc("E") Escalera
const It_stair_ur = 48  # Asc("0") Escalera Sube-Derecha
const It_stair_dl = 49  # Asc("1") Escalera Baja-Izquierda
const It_stair_ul = 50  # Asc("2") Escalera Sube-Izquierda
const It_stair_dr = 51  # Asc("3") Escalera Baja-Derecha
const It_push_in = 73  # Asc("I") Interruptor puerta entrada
const It_push_out = 79  # Asc("O") Interruptor puerta de salida

var HISCORE = 0
var SCORE = 0
var LIVES = 0

var snd_dead
var snd_digger
var snd_door
var snd_fall
var snd_jump
var snd_mummyappear
var snd_mummydead
var snd_rotadoor
var snd_takejewel
var snd_takepicker
var snd_dagger


func _ready():
	randomize()
	VisualServer.set_default_clear_color(Color(0, 0, 0, 1.0))
	load_sounds(true)


func is_android() -> bool:
	return tablet_mode


func get_sound_name(name, new_soundset) -> String:
	if new_soundset:
		return "res://assets/sound/" + name + "_new.wav"
	else:
		return "res://assets/sound/" + name + ".wav"


func load_sounds(new_soundset: bool):
	soundset_new = new_soundset
	snd_dead = load(Globals.get_sound_name("dead", new_soundset))
	snd_door = load(Globals.get_sound_name("door", new_soundset))
	snd_fall = load(Globals.get_sound_name("fall", new_soundset))
	snd_jump = load(Globals.get_sound_name("jump", new_soundset))
	snd_mummyappear = load(Globals.get_sound_name("mummyappear", new_soundset))
	snd_mummydead = load(Globals.get_sound_name("mummydead", new_soundset))
	snd_rotadoor = load(Globals.get_sound_name("rotadoor", new_soundset))
	snd_takejewel = load("res://assets/sound/takejewel.wav")
	snd_takepicker = load("res://assets/sound/takepicker.wav")
	snd_dagger = load("res://assets/sound/throwknife.wav")
	snd_digger = load("res://assets/sound/digger.wav")


func ray_cast_bodies(origin: Vector2, direction: Vector2) -> bool:
	return space_state.intersect_ray(origin, direction)


func ray_cast_areas(origin: Vector2, direction: Vector2) -> bool:
	return space_state.intersect_ray(origin, direction, [], 0x7FFFFFFF, false, true)


func play_sound(sound):
	if com_sound.playing:
		com_sound.stop()
	com_sound.stream = sound
	com_sound.play()


func play_music(music: int, loop = false):
	var stream
	if com_music.playing:
		com_music.stop()
	match music:
		MUSICS.ENDING:
			stream = load("res://assets/music/EndingGame.ogg")
		MUSICS.GAMEOVER:
			stream = load("res://assets/music/GameOver.ogg")
		MUSICS.GETREADY:
			stream = load("res://assets/music/GetReady.ogg")
		MUSICS.MENU:
			stream = load("res://assets/music/Menu.ogg")
		MUSICS.MUSIC1:
			stream = load("res://assets/music/Music01.ogg")
		MUSICS.MUSIC2:
			stream = load("res://assets/music/Music02.ogg")
		MUSICS.MUSIC3:
			stream = load("res://assets/music/Music03.ogg")
		MUSICS.MUSIC4:
			stream = load("res://assets/music/Music04.ogg")
		MUSICS.MUSIC5:
			stream = load("res://assets/music/Music05.ogg")
		MUSICS.PYRAMIDMAP:
			stream = load("res://assets/music/PyramidMap.ogg")

	stream.set_loop(loop)
	com_music.stream = stream
	com_music.play()


func stop_music():
	com_music.stop()


func pause_music():
	com_music.stream_paused = true


func resume_music():
	com_music.stream_paused = false


func get_music_player():
	return com_music


func connect_signal(source, signal_name, target, method_name, args = []):
	if not source.is_connected(signal_name, target, method_name):
		source.connect(signal_name, target, method_name, args)


func get_scene_name(scene: int) -> String:
	match scene:
		SCENES.KONAMI:
			return "res://scenes/TKonami.tscn"
		SCENES.MAINMENU:
			return "res://scenes/TMainMenu.tscn"
		SCENES.GAME:
			return "res://scenes/TGameScene.tscn"
		SCENES.GAMEOVER:
			return "res://scenes/TGameOver.tscn"
		SCENES.PYRAMIDMAP:
			return "res://scenes/TPyramidMap.tscn"
		SCENES.PYRAMID:
			return "res://scenes/TPyramidScreen.tscn"
		SCENES.ENDGAME:
			return "res://scenes/TGameEnd.tscn"
	return "unknow"


func load_scene(scene: int):
	return load(get_scene_name(scene))


func set_scene(scene: int):
	get_tree().change_scene(get_scene_name(scene))
