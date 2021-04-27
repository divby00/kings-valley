class_name TVick extends TSprite

signal sig_jewel_taken()
signal sig_level_done(level)
signal sig_update_score()
signal sig_vick_dead()

onready var tmagic = preload("res://items/TJewelParticles.tscn")
onready var tdagger = preload("res://sprites/TDagger.tscn")

enum PORTING { NONE=0, DAGGER=1, PICKER=2 }
var porting:int = PORTING.NONE
var falling:bool = true
var pyramid:TPyramidScreen = null
var pickingcells:Array = []

func get_class(): return "TVick"

func initGame():
	state=st_init
	porting=PORTING.NONE
	motion=Vector2.ZERO
	input_vector=Vector2.ZERO
		
func doControl():	
	
	if state in [st_init, st_goingout]:
		if state==st_init:
			motion = Vector2.ZERO
		return
				
	if state!=st_giratory:
		input_vector = Vector2.ZERO

		if Input.is_action_pressed("ui_left"):
			input_vector.x=-1
		elif Input.is_action_pressed("ui_right"):
			input_vector.x=1
		else:
			input_vector.x=0

		if Input.is_action_pressed("ui_up"):
			input_vector.y=-1
		elif Input.is_action_pressed("ui_down"):
			input_vector.y=1
		else:
			input_vector.y=0
			
		key_action = Input.is_action_just_pressed("ui_select")
		
	match state:
		st_walk:
			if motion.y > 30:
				if not falling:
					falling = true
					playSound(Globals.snd_fall)
			else:
				falling = false
			
			#Caso que pulse la tecla de acción, hay que decidir que hacer.
			if key_action:
				match porting:
					PORTING.NONE:
						if is_on_floor():
							doJump()
							playSound(Globals.snd_jump)
					PORTING.DAGGER:
						var dagger:TDagger=tdagger.instance()						
						dagger.doFlip(sprite.scale.x<0)
						dagger.position = self.position
						dagger.position.y -= 12
						porting = PORTING.NONE
						dagger.add_collision_exception_with(self)
						var _ret = dagger.connect("on_floor",self.get_parent(),"dagger_on_floor")
						self.get_parent().add_child(dagger)
						playSound(Globals.snd_dagger)
					PORTING.PICKER:
						pickingcells = pyramid.whereCanVickPick()
						if pickingcells.size()>0:
							porting = PORTING.NONE
							state = st_picking
							animator.play("picking")					
		
func doAnimation():
	if state in [st_walk,st_onstairs,st_init,st_goingout,st_giratory]:
		if input_vector.x != 0:
			sprite.scale.x = sign(input_vector.x)
			match porting:
				PORTING.NONE:
					animator.play("walk")
				PORTING.DAGGER:
					animator.play("walk_dagger")
				PORTING.PICKER:
					animator.play("walk_picker")
		else:
			match porting:
				PORTING.NONE:
					animator.play("stop")
				PORTING.DAGGER:
					animator.play("stop_dagger")
				PORTING.PICKER:
					animator.play("stop_picker")
					
	elif state in [st_jump_left,st_jump_right,st_jump_top]:
		match porting:
			PORTING.NONE:
				animator.play("jump")
			PORTING.DAGGER:
				animator.play("jump_dagger")
			PORTING.PICKER:
				animator.play("jump_picker")
				
func on_jewel_enter(area,jewel):
	if (area==$FeetDetect):
		playSound(Globals.snd_takejewel)
		var magic:TJewelParticles = tmagic.instance()
		magic.position.x = jewel.position.x + 5
		magic.position.y = jewel.position.y + 5
		jewel.queue_free()
		self.get_parent().add_child(magic)
		emit_signal("sig_jewel_taken")
		addScore(500)
	
func on_picker_enter(body,picker):
	if (body==self and porting==PORTING.NONE):
		playSound(Globals.snd_takepicker)
		porting=PORTING.PICKER
		picker.queue_free()

func on_dagger_enter(body,dagger):
	if (body==self and porting==PORTING.NONE):
		playSound(Globals.snd_takepicker)
		porting=PORTING.DAGGER
		dagger.queue_free()

func on_digger(frame:int):
	pyramid.pickCell(pickingcells[0],frame)
	if frame<4:
		playSound(Globals.snd_digger)
	else:
		pickingcells.remove(0)
		if pickingcells.size()>0:
			animator.play("picking")
		else:
			motion = Vector2.ZERO
			state=st_walk

func addScore(points):
	if (int(Globals.SCORE/10000) < int((Globals.SCORE+points)/10000)) and Globals.LIVES<99:
		Globals.LIVES+=1
	Globals.SCORE+=points
	if Globals.HISCORE<Globals.SCORE:
		Globals.HISCORE=Globals.SCORE
	emit_signal("sig_update_score")

func doDead():
	state = st_dying
	doBrickCollision(true)
	input_vector=Vector2.ZERO
	motion=Vector2.ZERO
	Globals.stopMusic()
	Globals.playSound(Globals.snd_dead)
	animator.play("die")
	yield(animator,"animation_finished")
	Globals.LIVES-=1
	if Globals.LIVES>=0:
		emit_signal("sig_update_score")
	emit_signal("sig_vick_dead")
	
func goNextLevel():
	state=st_leveldone
	emit_signal("sig_level_done",pyramid.level+1)

func goPrevLevel():
	state=st_leveldone
	emit_signal("sig_level_done",pyramid.level-1)
