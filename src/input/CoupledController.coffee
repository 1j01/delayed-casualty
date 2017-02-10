
class @CoupledController extends Controller
	constructor: (@controllers...)->
		super
	update: ->
		for controller in @controllers
			controller.update()
		
		for prop in @props
			@[prop] = if typeof @controllers[0][prop] is "boolean" then no else 0
			for controller in @controllers
				@[prop] ||= controller[prop]
		
		super
