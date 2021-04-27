class_name TPyramidScreen extends Control

signal sig_update_score(score,hiscore,rest,pyramid)
signal sig_next_level(currentlevel,nextlevel)
signal sig_restart_level()
signal sig_show_gameoptions()

class TLevelItem:
	var type:int
	var x:int
	var y:int
	var p0:int
	var p1:int

onready var Vick = $TVick
onready var tjewel = preload("res://items/TJewel.tscn")
onready var titem = preload("res://items/TItem.tscn")
onready var tdoor = preload("res://items/TDoor.tscn")
onready var tgdoor = preload("res://items/TDoorGiratory.tscn")
onready var tstairdetect = preload("res://items/TStairDetect.tscn")
onready var tstair = preload("res://items/TStair.tscn")
onready var twall = preload("res://items/TWall.tscn")
onready var tmummy = preload("res://sprites/TMummy.tscn")

var level:int=0
var from_level:int=0
var width:int
var height:int
var jewels:int
var backBuffer:Array
var frontBuffer:Array
var items:Array

func _ready():
	Vick.pyramid = self
	drawPyramid()
	setVickInitialPosition()

func _process(_delta):	
	$Camera.position = Vick.position
	if Input.is_action_just_pressed("ui_home") && Vick.visible:
		if !get_tree().paused and not Vick.state in [Vick.st_dying,Vick.st_init,Vick.st_goingout,Vick.st_leveldone]:
			emit_signal("sig_show_gameoptions")
		
func setLevel(l,pfrom):
	level=l
	from_level=pfrom
	readLevel(level)
		
func drawTile(layer,x,y,id):	
	layer.set_cell(x,y,0,false,false,false,Vector2(id % 20,int(id/20)))

func drawFrontTile(x,y,id):	
	$LayerFront.set_cell(x,y,0,false,false,false,Vector2(id % 20,int(id/20)))

func clearTile(layer,x,y):
	layer.set_cell(x,y,-1)

func getBufferValue(buffer,x,y)->int:
	if y>height-1: y=height-1
	return buffer[y*width+x]

func setBufferValue(buffer,x,y,value)->void:
	buffer[y*width+x]=value

func readLevel(plevel):
	var file = File.new()
	var nlevel=str(plevel)
	if nlevel.length()<2:
		nlevel="0"+nlevel
	file.open("res://levels/level."+nlevel, File.READ)
	width = file.get_8()
	height = file.get_8()
	backBuffer = Array(file.get_buffer(width*height))
	frontBuffer = Array(file.get_buffer(width*height))
	
	#Pasamos los tiles de escaleras que están en la capa front a la capa back
	for y in range(0,height):
		for x in range(0,width):
			var value = getBufferValue(frontBuffer,x,y)
			if value in [23,24,27,28,31,32,35,36,43,44,47,48,51,52,55,56]:
				setBufferValue(frontBuffer,x,y,0)
				setBufferValue(backBuffer,x,y,value)
	
	var nitems:int = file.get_8()
	items.clear()
	while nitems>0:
		nitems = nitems - 1
		var item:TLevelItem = TLevelItem.new()
		item.type = file.get_8()
		item.x = file.get_8()
		item.y = file.get_8()
		item.p0 = file.get_8()
		match item.type:
			Globals.It_giratory:
				item.p1 = file.get_8()
			Globals.It_stairs:
				item.p0 = item.p0 + Globals.It_stair_ur
			Globals.It_wall:
				item.p1 = file.get_8()
			Globals.It_giratory:
				item.p1 = file.get_8()
		items.append(item)
	file.close()
	$Camera.limit_left=0
	$Camera.limit_top=0
	$Camera.limit_right=width*10
	$Camera.limit_bottom=height*10
	self.rect_size=Vector2(width*10,height*10)
		
func drawBufferOnLayer(buffer,layer):
	for y in range(0,height):
		for x in range(0,width):
			var value = getBufferValue(buffer,x,y)
			if value>0:
				drawTile(layer,x,y,value-1)
			else:
				clearTile(layer,x,y)

func removeChildrens(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func drawPyramid():
	var _ret
	$LayerBack.clear()
	$LayerFront.clear()
	$LayerPick.clear()
	removeChildrens($Jewels)
	removeChildrens($Daggers)
	removeChildrens($Pickers)
	removeChildrens($Doors)
	removeChildrens($DoorsGiratory)
	removeChildrens($Stairs)
	removeChildrens($Walls)
	removeChildrens($Mummies)
	jewels=0
	$Mummies.visible=false
	drawBufferOnLayer(backBuffer,$LayerBack)
	drawBufferOnLayer(frontBuffer,$LayerFront)
	for item in items:
		match item.type:
			Globals.It_jewel:
				var jewel:TJewel = tjewel.instance()
				jewel.position.x = item.x*10
				jewel.position.y = item.y*10
				jewel.init_frame = item.p0-1
				$Jewels.add_child(jewel)
				_ret=jewel.connect("area_entered",Vick,"on_jewel_enter",[jewel])
				jewels+=1
				
			Globals.It_dagger:
				putDaggerOnFloor(item.x,item.y,item.p0-1)

			Globals.It_picker:
				var picker:TItem = titem.instance()
				picker.position.x = item.x*10
				picker.position.y = item.y*10
				picker.init_frame = item.p0-1
				$Pickers.add_child(picker)
				_ret=picker.connect("body_entered",Vick,"on_picker_enter",[picker])

			Globals.It_door:
				var door:TDoor = tdoor.instance()
				door.position.x = item.x*10
				door.position.y = item.y*10
				door.door_type = item.p0
				door.Vick=Vick
				_ret=door.connect("door_exiting",self,"on_door_exiting")
				$Doors.add_child(door)
				
			Globals.It_giratory:
				var gdoor:TDoorGiratory = tgdoor.instance()
				gdoor.position.x = item.x*10
				gdoor.position.y = item.y*10
				gdoor.height = item.p0
				gdoor.direction = item.p1
				$DoorsGiratory.add_child(gdoor)
				
			Globals.It_wall:
				var wall:TWall = twall.instance()
				wall.doInit(self,item.x,item.y,item.p0,item.p1)
				$Walls.add_child(wall)
				
			Globals.It_stairs:
				var staird:TStairDetect = tstairdetect.instance()
				match item.p0:
					Globals.It_stair_dl:
						staird.stair_type = TStairDetect.STAIR_TYPE.DOWN_LEFT
						item.x+=1
						item.y-=1
						var stair = tstair.instance()
						stair.position.x = (item.x - 1)*10
						stair.position.y = (item.y + 1)*10
						$Stairs.add_child(stair)
						stair = tstair.instance()
						stair.position.x = item.x*10
						stair.position.y = (item.y + 1)*10
						$Stairs.add_child(stair)
						
					Globals.It_stair_dr:
						staird.stair_type = TStairDetect.STAIR_TYPE.DOWN_RIGHT
						item.x-=1
						item.y-=1
						var stair = tstair.instance()
						stair.position.x = (item.x + 1)*10
						stair.position.y = (item.y + 1)*10
						$Stairs.add_child(stair)
						stair = tstair.instance()
						stair.position.x = item.x*10
						stair.position.y = (item.y + 1)*10
						$Stairs.add_child(stair)
						
					Globals.It_stair_ur:
						staird.stair_type = TStairDetect.STAIR_TYPE.UP_RIGHT
						
					Globals.It_stair_ul:
						staird.stair_type = TStairDetect.STAIR_TYPE.UP_LEFT
				
				staird.position.x = item.x*10
				staird.position.y = item.y*10
				$Stairs.add_child(staird)
				
			Globals.It_mummy:
				var mummy:TMummy = tmummy.instance()
				mummy.pyramid=self
				mummy.position.x = item.x*10+5
				mummy.position.y = item.y*10+9
				mummy.mode = mummy.MODE.APPEAR
				if item.p0==0:
					mummy.color=mummy.COLOR.WHITE
				elif item.p0==1:
					mummy.color=mummy.COLOR.BLUE
				elif item.p0==2:
					mummy.color=mummy.COLOR.YELLOW
				elif item.p0==3:
					mummy.color=mummy.COLOR.ORANGE
				elif item.p0==4:
					mummy.color=mummy.COLOR.RED
				mummy.vick=Vick
				_ret=mummy.connect("sig_vick_collision",self,"on_vick_collision")
				$Mummies.add_child(mummy)

	#Asociamos los eventos de detección de escaleras sobre Vick y las momias
	for staird in $Stairs.get_children():
		if staird.get_class()=="TStairDetect":
			_ret=staird.connect("area_entered",Vick,"on_stair_enter",[staird])
			_ret=staird.connect("area_exited",Vick,"on_stair_exit",[staird])
			for mummy in $Mummies.get_children():
				_ret=staird.connect("area_entered",mummy,"on_stair_enter",[staird])
				_ret=staird.connect("area_exited",mummy,"on_stair_exit",[staird])
				
	#Eliminamos a Vick de la Escena, para introducirlo en la puerta correspondiente
	remove_child(Vick)
	Vick.initGame()
	
	#Actualizamos los contadores
	_on_TVick_sig_update_score()

func putDaggerOnFloor(px,py,frame):
	var ldagger:TItem = titem.instance()
	if px<1:
		px=1
		
	if px>width-2:
		px=width-2
		
	ldagger.position.x = px*10
	ldagger.position.y = py*10
	ldagger.init_frame = frame
	$Daggers.add_child(ldagger)
	var _ret=ldagger.connect("body_entered",Vick,"on_dagger_enter",[ldagger])

func dagger_on_floor(dagger):	
	var pos:Vector2 = Vector2(int(dagger.position.x / 10),int(dagger.position.y / 10))
	while not isCellFreeForDagger(pos):
		if dagger.isFlip():
			dagger.position.x -= 5
		else:
			dagger.position.x += 5
		pos = Vector2(int(dagger.position.x / 10),int(dagger.position.y / 10))
	
	while pos.y < height-1 and not isBrick(pos.x,pos.y+1): pos.y+=1	
	putDaggerOnFloor(pos.x,pos.y,175)
	dagger.queue_free()

#Determina si una celdilla esta libre para poder poner un item
func isCellFreeForDagger(position:Vector2) -> bool:
	var ipos:Vector2	
	for i in $Jewels.get_children():
		ipos = Vector2(int(i.position.x / 10),int(i.position.y / 10))
		if ipos==position:
			return false
	for i in $Daggers.get_children():
		ipos = Vector2(int(i.position.x / 10),int(i.position.y / 10))
		if ipos==position:
			return false
	for i in $Pickers.get_children():
		ipos = Vector2(int(i.position.x / 10),int(i.position.y / 10))
		if ipos==position:
			return false					
	return true

#Determina si la celdilla indicada está en un muro o una puerta giratoria
func isGiratoryOrWall(position:Vector2) -> bool:
	var ipos:Vector2
	for i in $Walls.get_children():
		ipos = Vector2(int(i.position.x / 10),int(i.position.y / 10))
		if ipos==position:
			return true
	for i in $DoorsGiratory.get_children():
		ipos = Vector2(int(i.position.x / 10),int(i.position.y / 10))
		if ipos.x<=position.x and position.x<=ipos.x+1:
			return true
	return false		
		
func isPickableBrick(px:int,py:int) -> bool:
	var brick = getBufferValue(frontBuffer,px,py)
	return !(brick in [0, 21,22,25,26,29,30,33,34, 41,42,45,46,49,50,53,54])

func isBrick(px:int,py:int) -> bool:
	return getBufferValue(frontBuffer,px,py)>0

func isLocked(sprite) -> bool:
	var pos:Vector2 = sprite.position
	pos.x = int(pos.x/10)
	pos.y = int(pos.y/10)
	
	#Miramos si está encerrado
	return (isBrick(int(pos.x-1),int(pos.y-1)) and isBrick(int(pos.x+1),int(pos.y-1))) or\
		(isBrick(int(pos.x-1),int(pos.y)) and isBrick(int(pos.x+1),int(pos.y)))

func isFloorDown(sprite) -> bool:
	var pos:Vector2 = sprite.position
	pos.x = int(pos.x/10)
	pos.y = int(pos.y/10)
	return (isBrick(int(pos.x),int(pos.y+1)))

func canJumpLeft(sprite) -> bool:
	var pos:Vector2 = sprite.position
	pos.x = int(pos.x/10)
	pos.y = int(pos.y/10)
	if pos.x<=1: 
		return false
	return not (isBrick(int(pos.x-1),int(pos.y-1)) or isBrick(int(pos.x-1),int(pos.y-2)))

func isFloorLeft(sprite) -> bool:
	var pos:Vector2 = sprite.position
	pos.x = int((pos.x-1)/10)
	pos.y = int(pos.y/10)
	return (isBrick(int(pos.x),int(pos.y+1)))

func canJumpRight(sprite) -> bool:
	var pos:Vector2 = sprite.position
	pos.x = int(pos.x/10)
	pos.y = int(pos.y/10)
	if pos.x>=width-1: 
		return false
	return not (isBrick(int(pos.x+1),int(pos.y-1)) or isBrick(int(pos.x+1),int(pos.y-2)))

func isFloorRight(sprite) -> bool:
	var pos:Vector2 = sprite.position
	pos.x = int((pos.x+1)/10)
	pos.y = int(pos.y/10)
	return (isBrick(int(pos.x),int(pos.y+1)))

func teleport(sprite):
	var done=false
	var cx
	var cy
	while not done:
		cx = 2+(randi() % (width-4))
		cy = 2+(randi() % (height-4))
		var dist = Vector2(cx,cy).distance_to(Vector2(Vick.position.x/10,Vick.position.y/10))
		done=not isBrick(cx,cy) and dist>8
		done=done and not isBrick(cx+1,cy)
		done=done and not isBrick(cx,cy-1)
		done=done and not isBrick(cx+1,cy-1)
		
	# Bajamos hasta tocar suelo
	while not isBrick(cx,cy+1):
		cy+=1
	sprite.position.x = cx*10+5
	sprite.position.y = cy*10+9

func whereCanVickPick() -> Array:
	var pos:Vector2 = Vick.position
	var result:Array = []
	
	pos.x = int(pos.x/10)
	pos.y = int(pos.y/10)
	
	#Miramos si Vick está encerrado
	if isPickableBrick(int(pos.x-1),int(pos.y-1)) and isPickableBrick(int(pos.x+1),int(pos.y-1)):
		#Si está encerrado, debe picar primero para los lados, a menos que esté en los límites de la pirámide
		if Vick.isFlip():
			if pos.x<=1:
				return result
			else:
				result.append(Vector2(pos.x-1,pos.y-1))
				if isPickableBrick(int(pos.x-1),int(pos.y)):
					result.append(Vector2(pos.x-1,pos.y))
		else:
			if pos.x>=width-2:
				return result
			else:
				result.append(Vector2(pos.x+1,pos.y-1))
				if isPickableBrick(int(pos.x+1),int(pos.y)):
					result.append(Vector2(pos.x+1,pos.y))
	else:
		#Como no está encerrado, debe picar en el suelo, pero no en los limites de la piramide.
		if Vick.isFlip() and pos.x<=1:
			return result
			
		if pos.x>=width-2 or pos.y>=height-2:
			return result
			
		#Corregimos la celdilla segun flip
		if Vick.isFlip():
			pos.x -= 1
		else:
			pos.x += 1
			
		# No se puede picar si debajo hay puertas giratorias o muros crecientes
		if isGiratoryOrWall(Vector2(pos.x,pos.y+1)):
			return result
		
		#Si delante hay un item, no se puede picar
		if not isCellFreeForDagger(Vector2(pos.x,pos.y)):
			return result
			
		#Si delante hay un muro, no se puede picar
		if isPickableBrick(int(pos.x),int(pos.y)):
			return result
				
		#Si debajo no hay muro, no se puede picar
		if not isPickableBrick(int(pos.x),int(pos.y+1)):
			return result
			
		#Podemos picar
		result.append(Vector2(pos.x,pos.y+1))
		if pos.y<height-3 and isPickableBrick(int(pos.x),int(pos.y+2)):
			result.append(Vector2(pos.x,pos.y+2))			
		
	return result

func pickCell(cell:Vector2,frame:int):
	if frame<4:
		drawTile($LayerPick,cell.x,cell.y,176+frame)
	else:
		clearTile($LayerPick,cell.x,cell.y)
		clearTile($LayerFront,cell.x,cell.y)
		setBufferValue(frontBuffer,cell.x,cell.y,0)

func setVickInitialPosition():
	for d in $Doors.get_children():
		if (from_level <= level and d.door_type in [TDoor.TYPE.IN,TDoor.TYPE.BOTH]) or \
			(from_level > level and d.door_type in [TDoor.TYPE.OUT,TDoor.TYPE.BOTH]):
			Vick.position = d.position + d.vickPosition()

func showDoors(enterlevel:bool):
	var wait_door = null
	for d in $Doors.get_children():
		d.setClose(enterlevel)
		d.visible = true
		d.ready_to_exit = not enterlevel
		if enterlevel:
			d.openDoor(true)
			if (from_level <= level and d.door_type in [TDoor.TYPE.IN,TDoor.TYPE.BOTH]) or \
				(from_level > level and d.door_type in [TDoor.TYPE.OUT,TDoor.TYPE.BOTH]):
				Vick.state = TSprite.st_init
				self.add_child(Vick)
				wait_door = d			
				
	if (wait_door!=null):
		yield(wait_door,"door_opened")
		$Timer.start(1)
		yield($Timer,"timeout")
		for d in $Doors.get_children():
			d.closeDoor(false)
		$Timer.start(1)
		yield($Timer,"timeout")
		for d in $Doors.get_children():
			d.visible=false
		Vick.state = TSprite.st_walk
		$Timer.start(0.5)
		yield($Timer,"timeout")
		playMusicLevel()
		$Mummies.visible=true
		for m in $Mummies.get_children():
			m.setState(m.st_appearing)

func playMusicLevel():
	match (level % 5):
		1:
			Globals.playMusic(Globals.MUSICS.MUSIC1,true)
		2:
			Globals.playMusic(Globals.MUSICS.MUSIC2,true)
		3:
			Globals.playMusic(Globals.MUSICS.MUSIC3,true)
		4:
			Globals.playMusic(Globals.MUSICS.MUSIC4,true)
		0:
			Globals.playMusic(Globals.MUSICS.MUSIC5,true)
		
func doDead():
	Vick.doDead()

func killMummies():
	for m in $Mummies.get_children():
		m.setState(m.st_disappearing)
	
func on_door_exiting():
	killMummies()
	
func on_vick_collision():
	killMummies()
	doDead()
				
func _on_TVick_sig_jewel_taken():
	jewels-=1
	if jewels==0:
		showDoors(false)

func _on_TVick_sig_level_done(plevel):
	Globals.stopMusic()
	emit_signal("sig_next_level",level,plevel)
	
func _on_TVick_sig_update_score():
	emit_signal("sig_update_score",Globals.SCORE,Globals.HISCORE,Globals.LIVES,level)

func _on_TVick_sig_vick_dead():
	emit_signal("sig_restart_level")