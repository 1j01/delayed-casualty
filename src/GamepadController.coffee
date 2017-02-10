
BUTTONS =
  FACE_1: 0 # Face (main) buttons
  FACE_2: 1
  FACE_3: 2
  FACE_4: 3
  LEFT_SHOULDER: 4 # Top shoulder buttons
  RIGHT_SHOULDER: 5
  LEFT_SHOULDER_BOTTOM: 6 # Bottom shoulder buttons
  RIGHT_SHOULDER_BOTTOM: 7
  SELECT: 8
  START: 9
  LEFT_ANALOGUE_STICK: 10 # Analogue sticks (if depressible)
  RIGHT_ANALOGUE_STICK: 11
  PAD_TOP: 12 # Directional (discrete) pad
  PAD_BOTTOM: 13
  PAD_LEFT: 14
  PAD_RIGHT: 15

AXES =
  LEFT_ANALOGUE_HOR: 0
  LEFT_ANALOGUE_VERT: 1
  RIGHT_ANALOGUE_HOR: 2
  RIGHT_ANALOGUE_VERT: 3

class @GamepadController
	constructor: (@gp_index=0)->
		@prev_buttons = {}
	
	update: ->
		gp = navigator.getGamepads()[@gp_index]
		
		button_codes =
			right: [BUTTONS.PAD_RIGHT]
			left: [BUTTONS.PAD_LEFT]
			jump: [BUTTONS.FACE_1]
			descend: [BUTTONS.PAD_DOWN]
			attack: [BUTTONS.FACE_3]
			block: [BUTTONS.FACE_2]
			genuflect: [BUTTONS.LEFT_SHOULDER_BOTTOM, BUTTONS.RIGHT_SHOULDER_BOTTOM]
		
		pressed = (control_name)=>
			return no unless gp
			for button_index in button_codes[control_name]
				return yes if gp.buttons[button_index]?.pressed
			return no
		just_pressed = (control_name)=>
			return no unless gp
			for button_index in button_codes[control_name]
				return yes if gp.buttons[button_index]?.pressed and not @prev_buttons[button_index]?.pressed
			return no
		
		axis = (axis_index)=>
			value = (gp?.axes[axis_index] ? 0)
			# if abs(value) > 0.5 then value else 0
			if abs(value) > 0.5 then sign(value) else 0
		
		# TODO: control high jump etc. with the stick
		@x = pressed("right") - pressed("left") + axis(AXES.LEFT_ANALOGUE_HOR)
		@start_jump = just_pressed("jump") #or axis(AXES.LEFT_ANALOGUE_VERT) < 0
		@extend_jump = pressed("jump") or axis(AXES.LEFT_ANALOGUE_VERT) < 0
		@descend = pressed("descend") or axis(AXES.LEFT_ANALOGUE_VERT) > 0
		@attack = just_pressed("attack")
		@block = just_pressed("block")
		@genuflect = pressed("genuflect")
		
		delete @prev_buttons[k] for k, v of @prev_buttons
		@prev_buttons[k] = {pressed: v.pressed, value: v.value} for k, v of gp.buttons when v if gp
