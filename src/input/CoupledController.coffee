
class @CoupledController
	constructor: (@controllers...)->
		
	update: ->
		for controller in @controllers
			controller.update()
		
		props = ["x", "start_jump", "extend_jump", "descend", "attack", "block", "genuflect"]
		for prop in props
			@[prop] = no
			for controller in @controllers
				@[prop] ||= controller[prop]
