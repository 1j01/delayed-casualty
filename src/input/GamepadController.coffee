
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

class @GamepadController extends Controller
	constructor: (@gp_index=0)->
		super
	
	update: ->
		gp = navigator.getGamepads()[@gp_index]
		
		button_codes =
			right: [BUTTONS.PAD_RIGHT]
			left: [BUTTONS.PAD_LEFT]
			jump: [BUTTONS.FACE_1] # not BUTTONS.PAD_TOP; we'd want to I guess trigger a jump if you switch directions for this to work
			descend: [BUTTONS.PAD_BOTTOM]
			attack: [BUTTONS.RIGHT_SHOULDER_BOTTOM, BUTTONS.RIGHT_SHOULDER, BUTTONS.FACE_3]
			block: [BUTTONS.LEFT_SHOULDER_BOTTOM, BUTTONS.LEFT_SHOULDER, BUTTONS.FACE_2]
			genuflect: [BUTTONS.FACE_4]
		
		pressed = (control_name)=>
			return no unless gp
			for button_index in button_codes[control_name]
				throw new Error "Invalid button index: #{button_index}" unless button_index?
				return yes if gp.buttons[button_index]?.pressed
			return no
		
		axis = (axis_index)=>
			value = (gp?.axes[axis_index] ? 0)
			if abs(value) > 0.5 then sign(value) else 0
		
		# TODO: control high jump etc. with the stick
		@x = pressed("right") - pressed("left") + axis(AXES.LEFT_ANALOGUE_HOR)
		@jump = pressed("jump")
		@descend = pressed("descend") or axis(AXES.LEFT_ANALOGUE_VERT) > 0
		@attack = pressed("attack")
		@block = pressed("block")
		@genuflect = pressed("genuflect")
		
		super
		
		# FIXME: gamepad support is poor
		# trying to reach attack and block and jump, all with face buttons
		# trying to jump around using both a face button and the stick
		# but we can't just 
		# @jump = pressed("jump") # NOT if axis(AXES.LEFT_ANALOGUE_VERT) < 0
