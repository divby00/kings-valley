tool
extends Node2D

const FontWidth = 8
const FontHeight = 8
const Fuente = preload("res://fonts/KVFont.tscn")
const chars = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ ?¿,.0123456789<>'-&:"

export (String) var text setget setText
export (int,"top-left","top-middle","top-right","middle-left","middle","middle-right","bottom-left","bottom-middle","bottom-right") var textalign=0 setget setTextAlign 

export (float,1,20,1) var waves = 1 setget setWaves
export (float,1,30,1) var wavesize = 10 setget setWaveSize
export (float,1,300) var wavespeed = 10 setget setWaveSpeed
export (bool) var animatewaves = false setget setAnimateWaves

var wavesvalues = []
var indexwavesvalues=0
var offx=0
var offy=0

# Called when the node enters the scene tree for the first time.
func _ready():
	createText()

func createText():
	var letra
	var texto = text.to_upper()
	var textsize = texto.length()*FontWidth
	
	while (get_child_count()>0):
		var child = get_child(0)
		remove_child(child)
		child.queue_free()
		
	if textalign==0 or textalign==3 or textalign==6:
		offx = 0
	elif textalign==1 or textalign==4 or textalign==7:
		offx = -textsize/2
	elif textalign==2 or textalign==5 or textalign==8:
		offx = -textsize
		
	if textalign==0 or textalign==1 or textalign==2:
		offy = 0
	elif textalign==3 or textalign==4 or textalign==5:
		offy = -float(FontHeight)/2
	elif textalign==6 or textalign==7 or textalign==8:
		offy = -FontHeight
		
	for i in range (0,texto.length()):
		var index = chars.find(texto[i])
		letra = Fuente.instance()
		add_child(letra)
		letra.position.x += FontWidth*i + offx
		letra.position.y = offy
		letra.frame=index
	_calculateWaves()
		
func setText(t):
	text = t
	createText()

func setTextAlign(align):
	textalign = align
	createText()
	
func _calculateWaves():
	wavesvalues.clear()
	var textsize = text.length()*FontWidth
	for i in range(0,textsize):
		wavesvalues.push_back(sin(((PI)*waves*i)/textsize)*wavesize)
	update()
	
func setWaves(w):
	waves=w
	_calculateWaves()
	
func setWaveSize(ws):
	wavesize=ws
	_calculateWaves()
	
func setAnimateWaves(anim):
	animatewaves=anim
	if (not anim):
		createText()

func setWaveSpeed(sp):
	wavespeed = sp

func _process(delta):
	if (not animatewaves or text.length()==0):
		return

	indexwavesvalues+=delta*wavespeed
	var index:int = indexwavesvalues
	index = index % wavesvalues.size()
	for child in range(0,get_child_count()):
		var letra = get_child(child)
		letra.position.y = offy + wavesvalues[int(index + letra.position.x) % wavesvalues.size()]
	
	if (Engine.editor_hint):
		update()
		
func _draw():
	if (Engine.editor_hint):
		for i in range(0,wavesvalues.size()):
			draw_circle(Vector2(offx+i,wavesvalues[i]),1,Color("#ffff00"))
		
