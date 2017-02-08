
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
		
		# for controller in @controllers
		# 	for k, v of controller
		# 		console.log k, typeof v
		# 	for k, v of controller when typeof v is "boolean"
		# 		@[k] = no
		# 
		# for controller in @controllers
		# 	for k, v of controller when typeof v is "boolean"
		# 		@[k] ||= v
		
		
