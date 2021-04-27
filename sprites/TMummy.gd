class_name TMummy extends TSprite

signal sig_vick_collision

enum COLOR {WHITE=0,BLUE=1,YELLOW=2,ORANGE=3,RED=4}
enum MODE {MUMMY,APPEAR,DISAPPEAR}

export (COLOR) var color=COLOR.WHITE setget setColor
export (MODE) var mode=MODE.MUMMY setget setMode

var vick
var pyramid
var texture_mummy:Texture
var texture_appear:Texture
var texture_disappear:Texture
var decision_factor = 0.5

func get_class(): return "TMummy"

func _ready():
	setState(st_limbus)

func makeDecision()->bool:
	return rand_range(0,1)<=decision_factor

func makeDecisionForJump()->bool:
	return rand_range(0,1)<=decision_factor/2

func makeDecisionForContinue()->bool:
	return rand_range(0,1)<=0.6
	
func setColor(c):
	color=c
	match color:
		COLOR.WHITE:
			texture_mummy=load("res://pics/mummy_white.png")
			speed_walk=25
			speed_walk_stairs=30
			decision_factor=0.5 #03
		COLOR.BLUE:
			texture_mummy=load("res://pics/mummy_blue.png")
			speed_walk=45
			speed_walk_stairs=50
			decision_factor=0.5
		COLOR.YELLOW:
			texture_mummy=load("res://pics/mummy_yellow.png")
			speed_walk=50
			speed_walk_stairs=60
			decision_factor=0.3
		COLOR.ORANGE:
			texture_mummy=load("res://pics/mummy_orange.png")
			speed_walk=60
			speed_walk_stairs=70
			decision_factor=0.4
		COLOR.RED:
			texture_mummy=load("res://pics/mummy_red.png")
			speed_walk=65
			speed_walk_stairs=75
			decision_factor=0.5
			
	texture_appear=load("res://pics/mummy_appear.png")
	texture_disappear=load("res://pics/mummy_disappear.png")
	$Sprite.texture=texture_mummy
	update()

func setMode(m):
	mode=m
	match mode:
		MODE.MUMMY:
			$Sprite.texture=texture_mummy
			$Sprite.hframes=11
			self.set_collision_layer_bit(16,true) #Habilita la colisión
		MODE.APPEAR:
			$Sprite.texture=texture_appear
			$Sprite.hframes=10
			self.set_collision_layer_bit(16,false) #Deshabilita la colisión
		MODE.DISAPPEAR:
			$Sprite.texture=texture_disappear
			$Sprite.hframes=5
			self.set_collision_layer_bit(16,false) #Deshabilita la colisión
	$Sprite.frame=1
	update()

func setState(st):
	self.state=st
	$Timer.stop()
	match self.state:
		st_init:
			setState(st_appearing)
						
		st_appearing:
			Globals.playSound(Globals.snd_mummyappear)
			setMode(MODE.APPEAR)
			motion=Vector2.ZERO
			input_vector=Vector2.ZERO
			input_vector.x = -1 if vick.position.x < self.position.x else 1	
			animator.play("appear")
			self.visible=true
			yield(animator,"animation_finished")
			setState(st_waiting)
			
		st_disappearing:
			setMode(MODE.DISAPPEAR)
			motion=Vector2.ZERO
			input_vector=Vector2.ZERO
			animator.play("disappear")
			yield(animator,"animation_finished")
			#Programamos la aparición después de 5 segundos
			$Timer.start(5)

		st_teleporting:
			setMode(MODE.DISAPPEAR)
			motion=Vector2.ZERO
			input_vector=Vector2.ZERO
			animator.play("disappear")
			yield(animator,"animation_finished")
			pyramid.teleport(self)
			#Programamos la aparición en medio segundo
			$Timer.start(0.5)
			
		st_waiting:
			setMode(MODE.MUMMY)
			animator.play("waiting")
			$Timer.start(rand_range(1.5,2.5))
			
		st_walk:
			#Establecemos un tiempo tras el cual, volvemos a decidir que hacer
			match color:
				COLOR.WHITE:
					$Timer.start(rand_range(5,10))
				COLOR.BLUE:
					$Timer.start(rand_range(5,8))
				COLOR.YELLOW:
					$Timer.start(rand_range(5,6))
				COLOR.ORANGE:
					$Timer.start(5)
				COLOR.RED:
					$Timer.start(rand_range(3,5))

func doControl():	
	if state in [st_init]:
		if state==st_init:
			motion = Vector2.ZERO
		return		
						
func doAnimation():
	sprite.scale.x = -1 if input_vector.x<0 else 1
	if state in [st_walk,st_onstairs]:
		if input_vector.x != 0:
			animator.play("walk")					
	elif state in [st_jump_left,st_jump_right,st_jump_top]:
		animator.play("jump")
			
func doAfterMove():
	if state==st_walk:
		if is_on_wall():
			input_vector.y=0
			if pyramid.isLocked(self):
				doJump()
			else:
				if isFlip():
					if color!=COLOR.WHITE && pyramid.canJumpLeft(self) && makeDecisionForJump():
						doJump()
						return
				else:
					if color!=COLOR.WHITE && pyramid.canJumpRight(self) && makeDecisionForJump():
						doJump()
						return
				input_vector.x = -input_vector.x
		else:
			if not pyramid.isFloorDown(self):
				if vick.position.y > self.position.y || makeDecisionForContinue():
					return
				elif color!=COLOR.WHITE && makeDecisionForJump():
					doJump()
				else:
					input_vector.x = -input_vector.x
	
func doKill()->bool:
	if state in [st_walk,st_waiting,st_falling,st_jump_left,st_jump_right,st_jump_top,st_onstairs]:
		Globals.playSound(Globals.snd_mummydead)
		setState(st_disappearing)
		return true
	return false
					
func do_on_stair_enter():
	if state in [st_walk]:
		input_vector.y = 0
		if stair_cell.onstair:
			if vick.position.y < self.position.y-10:
				if stair_cell.stair_up!=null && makeDecision():
					input_vector.y = -1
					if stair_cell.stair_up.stair_type==TStairDetect.STAIR_TYPE.UP_LEFT:
						input_vector.x = -1
					else:
						input_vector.x = 1
			elif vick.position.y > self.position.y+10:
				if stair_cell.stair_down!=null && makeDecision():
					input_vector.y = 1
					if stair_cell.stair_down.stair_type==TStairDetect.STAIR_TYPE.DOWN_LEFT:
						input_vector.x = -1
					else:
						input_vector.x = 1
	
func do_on_stair_exit():
	if state in [st_walk]:
		if not stair_cell.onstair:
			#Se mueve hacia la dirección donde esta Vick si lo decide
			if makeDecision():
				input_vector.x = -1 if vick.position.x-30 < self.position.x else 1	
						
func _on_VickDetect_body_entered(body):
	if body.get_class()=="TVick" and body.state!=st_dying:
		if body.state==st_onstairs:
			if self.state==st_onstairs:
				emit_signal("sig_vick_collision")
		elif self.state==st_onstairs:
			if body.state==st_onstairs:
				emit_signal("sig_vick_collision")
		elif self.state in [st_walk,st_waiting,st_falling,st_jump_left,st_jump_right,st_jump_top]:
			emit_signal("sig_vick_collision")

func _on_Timer_timeout():
	if state in [st_walk,st_jump_left,st_jump_right,st_jump_top]:
		#Si no estamos en el suelo, esperamos un poco más hasta estarlo
		if not is_on_floor():
			$Timer.start(1)
		else:
			#Si estamos cerca de Vick, decidimos perseguirlo.
			if self.position.distance_to(vick.position)<80:
				setState(st_walk)
			else:
				#Decidimos si volver a caminar o teletransportarnos a otra posición
				if rand_range(0,1)<0.5:
					setState(st_waiting)
				else:
					setState(st_teleporting)
					
	elif state == st_waiting:
		input_vector.x = -1 if vick.position.x < self.position.x else 1
		setState(st_walk)

	elif state in [st_disappearing,st_teleporting]:
		setState(st_appearing)
