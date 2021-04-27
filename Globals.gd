extends Node2D

enum MUSICS {MENU=0,GETREADY=1,PYRAMIDMAP=2,GAMEOVER=3,ENDING=4,MUSIC1=5,MUSIC2=6,MUSIC3=7,MUSIC4=8,MUSIC5=9}

var tablet_mode = (OS.get_name()=="Android")
var soundset_new:bool=false

# ---------------------------------------------
# Constantes para identificar tipo de elementos
# ---------------------------------------------
const It_none = 0        # Nada
const It_brick = 76      # Asc("L") Ladrillo
const It_giratory = 71   # Asc("G") Puerta Giratoria
const It_rgiratory = 62  # Asc(">") Puerta Giratoria a Derecha
const It_lgiratory = 60  # Asc("<") Puerta Giratoria a Izquierda
const It_dagger = 68     # Asc("D") Daga
const It_picker = 80     # Asc("P") Pico
const It_jewel = 74      # Asc("J") Joya
const It_door = 84       # Asc("T") Puerta Entrada/Salida
const It_wall = 85       # Asc("U") Muro que aparece y crece
const It_mummy = 77      # Asc("M") Posicion de Momia
const It_stairs = 69     # Asc("E") Escalera
const It_stair_ur = 48   # Asc("0") Escalera Sube-Derecha
const It_stair_dl = 49   # Asc("1") Escalera Baja-Izquierda
const It_stair_ul = 50   # Asc("2") Escalera Sube-Izquierda
const It_stair_dr = 51   # Asc("3") Escalera Baja-Derecha
const It_push_in = 73    # Asc("I") Interruptor puerta entrada
const It_push_out = 79   # Asc("O") Interruptor puerta de salida

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

onready var comSound = $ComSound
onready var space_state = get_world_2d().direct_space_state

func _ready():
	randomize()
	VisualServer.set_default_clear_color(Color(0,0,0,1.0))
	loadSounds(true)
	
func isTablet()->bool:
	return tablet_mode
	
func getSoundName(name,new_soundset) -> String:
	if new_soundset:
		return "res://sound/"+name+"_new.wav"
	else:
		return "res://sound/"+name+".wav"

func loadSounds(new_soundset:bool):
	soundset_new=new_soundset
	snd_dead = load(Globals.getSoundName("dead",new_soundset))
	snd_door = load(Globals.getSoundName("door",new_soundset))
	snd_fall = load(Globals.getSoundName("fall",new_soundset))
	snd_jump = load(Globals.getSoundName("jump",new_soundset))
	snd_mummyappear = load(Globals.getSoundName("mummyappear",new_soundset))
	snd_mummydead = load(Globals.getSoundName("mummydead",new_soundset))
	snd_rotadoor = load(Globals.getSoundName("rotadoor",new_soundset))
	snd_takejewel = load("res://sound/takejewel.wav")
	snd_takepicker = load("res://sound/takepicker.wav")
	snd_dagger = load("res://sound/throwknife.wav")
	snd_digger = load("res://sound/digger.wav")
	
func ray_cast_bodies(origin:Vector2,direction:Vector2) -> bool:
	return space_state.intersect_ray(origin,direction)

func ray_cast_areas(origin:Vector2,direction:Vector2) -> bool:
	return space_state.intersect_ray(origin,direction,[],0x7FFFFFFF,false,true)
	
func playSound(sound):
	if comSound.playing: comSound.stop()
	comSound.stream = sound
	comSound.play()

func playMusic(music:int,loop=false):
	var stream
	if $ComMusic.playing:
		$ComMusic.stop()
	match music:
		MUSICS.ENDING:
			stream = load("res://music/EndingGame.ogg")
		MUSICS.GAMEOVER:
			stream = load("res://music/GameOver.ogg")
		MUSICS.GETREADY:
			stream = load("res://music/GetReady.ogg")
		MUSICS.MENU:
			stream = load("res://music/Menu.ogg")
		MUSICS.MUSIC1:
			stream = load("res://music/Music01.ogg")
		MUSICS.MUSIC2:
			stream = load("res://music/Music02.ogg")
		MUSICS.MUSIC3:
			stream = load("res://music/Music03.ogg")
		MUSICS.MUSIC4:
			stream = load("res://music/Music04.ogg")
		MUSICS.MUSIC5:
			stream = load("res://music/Music05.ogg")
		MUSICS.PYRAMIDMAP:
			stream = load("res://music/PyramidMap.ogg")

	stream.set_loop(loop)
	$ComMusic.stream = stream
	$ComMusic.play()

func stopMusic():
	$ComMusic.stop()

func pauseMusic():
	$ComMusic.stream_paused=true
	
func resumeMusic():
	$ComMusic.stream_paused=false

func getMusicPlayer():
	return $ComMusic
