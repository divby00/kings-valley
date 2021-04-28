tool
extends Node2D

const FONT_WIDTH = 8
const FONT_HEIGHT = 8
const CHARACTERS = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ ?¿,.0123456789<>'-&:"

const Fuente = preload("res://scenes/fonts/KVFont.tscn")

export (String) var text setget set_text
export (
	int,
	"top-left",
	"top-middle",
	"top-right",
	"middle-left",
	"middle",
	"middle-right",
	"bottom-left",
	"bottom-middle",
	"bottom-right"
) var textalign = 0 setget set_text_alignment

export (float, 1, 20, 1) var waves = 1 setget set_waves
export (float, 1, 30, 1) var wavesize = 10 setget set_wavesize
export (float, 1, 300) var wavespeed = 10 setget set_wave_speed
export (bool) var animatewaves = false setget set_animate_waves

var wavesvalues = []
var indexwavesvalues = 0
var offx = 0
var offy = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	create_text()


func create_text():
	var letra
	var texto = text.to_upper()
	var textsize = texto.length() * FONT_WIDTH

	while get_child_count() > 0:
		var child = get_child(0)
		remove_child(child)
		child.queue_free()

	if textalign == 0 or textalign == 3 or textalign == 6:
		offx = 0
	elif textalign == 1 or textalign == 4 or textalign == 7:
		offx = -textsize / 2
	elif textalign == 2 or textalign == 5 or textalign == 8:
		offx = -textsize

	if textalign == 0 or textalign == 1 or textalign == 2:
		offy = 0
	elif textalign == 3 or textalign == 4 or textalign == 5:
		offy = -float(FONT_HEIGHT) / 2
	elif textalign == 6 or textalign == 7 or textalign == 8:
		offy = -FONT_HEIGHT

	for i in range(0, texto.length()):
		var index = CHARACTERS.find(texto[i])
		letra = Fuente.instance()
		add_child(letra)
		letra.position.x += FONT_WIDTH * i + offx
		letra.position.y = offy
		letra.frame = index
	_calculate_waves()


func set_text(t):
	text = t
	create_text()


func set_text_alignment(align):
	textalign = align
	create_text()


func _calculate_waves():
	wavesvalues.clear()
	var textsize = text.length() * FONT_WIDTH
	for i in range(0, textsize):
		wavesvalues.push_back(sin(((PI) * waves * i) / textsize) * wavesize)
	update()


func set_waves(w):
	waves = w
	_calculate_waves()


func set_wavesize(ws):
	wavesize = ws
	_calculate_waves()


func set_animate_waves(anim):
	animatewaves = anim
	if not anim:
		create_text()


func set_wave_speed(sp):
	wavespeed = sp


func _process(delta):
	if not animatewaves or text.length() == 0:
		return

	indexwavesvalues += delta * wavespeed
	var index: int = indexwavesvalues
	index = index % wavesvalues.size()
	for child in range(0, get_child_count()):
		var letra = get_child(child)
		letra.position.y = offy + wavesvalues[int(index + letra.position.x) % wavesvalues.size()]

	if Engine.editor_hint:
		update()


func _draw():
	if Engine.editor_hint:
		for i in range(0, wavesvalues.size()):
			draw_circle(Vector2(offx + i, wavesvalues[i]), 1, Color("#ffff00"))
