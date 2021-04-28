class_name TSprite extends KinematicBody2D

#Estados comunes
const st_init = 0  # Inicializando
const st_walk = 1  # Andando
const st_onstairs = 2  # En una escalera
const st_falling = 3  # Cayendo
const st_jump_left = 4  # Saltando izquierda
const st_jump_top = 5  # Saltando arriba
const st_jump_right = 6  # Saltando derecha
const st_dying = 7  # Muriendo

#Estados Momia
const st_waiting = 100  # Esperando y decidiendo
const st_limbus = 101  # Antes de aparecer
const st_appearing = 102  # Apareciendo
const st_disappearing = 103  # Desapareciendo
const st_teleporting = 104  # Teletransporte

#Estados VICK
const st_picking = 200  # Picando
const st_throwdagger = 201  # Lanzando daga
const st_giratory = 202  # En puerta giratoria
const st_goingout = 203  # Saliendo de la piramide
const st_leveldone = 204  # Ha superado el nivel


class TStairCell:
	var onstair: bool = false
	var stair_up: TStairDetect = null
	var stair_down: TStairDetect = null


onready var sprite = $Sprite
onready var animator: AnimationPlayer = $Animator
onready var aplayer: AudioStreamPlayer = $AudioStreamPlayer
onready var stair_cell: TStairCell = TStairCell.new()
onready var feet_detect = $FeetDetect

var state: int = st_init
var input_vector: Vector2 = Vector2.ZERO
var snap_vector: Vector2 = Vector2.ZERO
var motion: Vector2 = Vector2.ZERO
var speed_fall: int = 600
var speed_walk: int = 60
var speed_walk_stairs: int = 60
var speed_jump: int = 160
var stair_init: int = Globals.It_none
var key_action: bool = false


func is_flip() -> bool:
	return sprite.scale.x < 0


func play_sound(sound):
	aplayer.stream = sound
	aplayer.play()


func do_brick_collision(enabled):
	self.set_collision_mask_bit(0, enabled)
	self.set_collision_mask_bit(1, enabled)


func _physics_process(delta):
	do_control()
	do_forces(delta)
	do_move(delta)
	do_after_move()
	do_animation()
	do_detect_stairs()


func do_control():
	pass


func do_jump():
	motion.y = -speed_jump
	if input_vector.x < 0:
		state = st_jump_left
	elif input_vector.x > 0:
		state = st_jump_right
	else:
		state = st_jump_top


func do_forces(delta):
	match state:
		st_jump_left:
			motion.x = -speed_walk
		st_jump_right:
			motion.x = speed_walk
		st_jump_top:
			motion.x = 0
		st_walk:
			if motion.y < 30:
				motion.x = input_vector.x * speed_walk
			else:
				motion.x = 0
		st_giratory:
# warning-ignore:integer_division
			motion.x = input_vector.x * (speed_walk / 2)
		st_onstairs:
			motion.x = input_vector.x * speed_walk_stairs
			motion.y = 0
			if stair_init in [TStairDetect.STAIR_TYPE.DOWN_LEFT, TStairDetect.STAIR_TYPE.UP_RIGHT]:
				if input_vector.x < 0:
					motion.y = speed_walk_stairs
				elif input_vector.x > 0:
					motion.y = -speed_walk_stairs
			elif (
				stair_init
				in [TStairDetect.STAIR_TYPE.DOWN_RIGHT, TStairDetect.STAIR_TYPE.UP_LEFT]
			):
				if input_vector.x < 0:
					motion.y = -speed_walk_stairs
				elif input_vector.x > 0:
					motion.y = speed_walk_stairs
		st_goingout:
			motion.x = 5
			motion.y = -5

	#Aplicamos la gravedad solo si no estamos en la escalera
	if not state in [st_onstairs, st_goingout]:
		motion.y += speed_fall * delta
		motion.y = min(motion.y, speed_fall)


func do_move(_delta):
	# Si está saltando, y empieza a caer, y detecta suelo, pasamos a caminar
	if state in [st_jump_left, st_jump_right, st_jump_top]:
		if is_on_floor() and motion.y > 0:
			state = st_walk
			motion = Vector2.ZERO

	if (
		state
		in [
			st_dying,
			st_walk,
			st_jump_left,
			st_jump_right,
			st_jump_top,
			st_onstairs,
			st_goingout,
			st_giratory
		]
	):
		motion = move_and_slide_with_snap(motion, snap_vector * 4, Vector2.UP, true, 4, deg2rad(0))


func do_animation():
	pass


func do_after_move():
	pass


func do_on_stair_enter():
	pass


func do_on_stair_exit():
	pass


func on_stair_enter(body, stair: TStairDetect):
	if body == feet_detect:
		stair_cell.onstair = true
		if stair.stair_type in [TStairDetect.STAIR_TYPE.UP_RIGHT, TStairDetect.STAIR_TYPE.UP_LEFT]:
			stair_cell.stair_up = stair
		else:
			stair_cell.stair_down = stair
		do_on_stair_enter()


func on_stair_exit(body, stair: TStairDetect):
	if body == feet_detect:
		if stair.stair_type in [TStairDetect.STAIR_TYPE.UP_RIGHT, TStairDetect.STAIR_TYPE.UP_LEFT]:
			stair_cell.stair_up = null
		else:
			stair_cell.stair_down = null
		if stair_cell.stair_up == null and stair_cell.stair_down == null:
			stair_cell.onstair = false
		do_on_stair_exit()


func do_detect_stairs():
	if ! stair_cell.onstair:
		return
	match state:
		st_walk:
			if stair_cell.stair_down != null and input_vector.y > 0:
				if not (
					(
						stair_cell.stair_down.stair_type == TStairDetect.STAIR_TYPE.DOWN_LEFT
						and input_vector.x < 0
					)
					or (
						stair_cell.stair_down.stair_type == TStairDetect.STAIR_TYPE.DOWN_RIGHT
						and input_vector.x > 0
					)
				):
					return

				state = st_onstairs
				stair_init = stair_cell.stair_down.stair_type
				if input_vector.x > 0:
					self.position.x = stair_cell.stair_down.position.x + 8
				else:
					self.position.x = stair_cell.stair_down.position.x + 3
				do_brick_collision(false)
				return

			if stair_cell.stair_up != null and input_vector.y < 0:
				if not (
					(
						stair_cell.stair_up.stair_type == TStairDetect.STAIR_TYPE.UP_LEFT
						and input_vector.x < 0
					)
					or (
						stair_cell.stair_up.stair_type == TStairDetect.STAIR_TYPE.UP_RIGHT
						and input_vector.x > 0
					)
				):
					return
				state = st_onstairs
				stair_init = stair_cell.stair_up.stair_type
				if input_vector.x > 0:
					self.position.x = stair_cell.stair_up.position.x + 3
				else:
					self.position.x = stair_cell.stair_up.position.x + 8
				do_brick_collision(false)
				return

		st_onstairs:
			if stair_init in [TStairDetect.STAIR_TYPE.DOWN_LEFT, TStairDetect.STAIR_TYPE.UP_RIGHT]:
				if input_vector.x > 0:
					if stair_cell.stair_down != null:
						if (
							stair_cell.stair_up != null
							and stair_cell.stair_up.stair_type == TStairDetect.STAIR_TYPE.UP_RIGHT
							and input_vector.y < 0
						):
							return
						else:
							state = st_walk
							motion.y = 0
							stair_init = stair_cell.stair_down.stair_type
							self.position.x = stair_cell.stair_down.position.x + 3
							do_brick_collision(true)

				elif input_vector.x < 0:
					if stair_cell.stair_up != null:
						if (
							stair_cell.stair_down != null
							and (
								stair_cell.stair_down.stair_type
								== TStairDetect.STAIR_TYPE.DOWN_LEFT
							)
							and input_vector.y > 0
						):
							return
						else:
							state = st_walk
							motion.y = 0
							stair_init = stair_cell.stair_up.stair_type
							self.position.x = stair_cell.stair_up.position.x + 3
							do_brick_collision(true)

			if stair_init in [TStairDetect.STAIR_TYPE.DOWN_RIGHT, TStairDetect.STAIR_TYPE.UP_LEFT]:
				if input_vector.x < 0:
					if stair_cell.stair_down != null:
						if (
							stair_cell.stair_up != null
							and stair_cell.stair_up.stair_type == TStairDetect.STAIR_TYPE.UP_LEFT
							and input_vector.y < 0
						):
							return
						else:
							state = st_walk
							motion.y = 0
							stair_init = stair_cell.stair_down.stair_type
							self.position.x = stair_cell.stair_down.position.x + 8
							do_brick_collision(true)
				elif input_vector.x > 0:
					if stair_cell.stair_up != null:
						if (
							stair_cell.stair_down != null
							and (
								stair_cell.stair_down.stair_type
								== TStairDetect.STAIR_TYPE.DOWN_RIGHT
							)
							and input_vector.y > 0
						):
							return
						else:
							state = st_walk
							motion.y = 0
							stair_init = stair_cell.stair_up.stair_type
							self.position.x = stair_cell.stair_up.position.x + 5
							do_brick_collision(true)
