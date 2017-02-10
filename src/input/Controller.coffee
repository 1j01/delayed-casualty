
class @Controller
	constructor: ->
		@props = ["x", "jump", "descend", "attack", "block", "genuflect"]
		@prev_values = {}
	
	update: ->
		for prop in @props when typeof @[prop] is "boolean"
			@["#{prop}_pressed"] = @[prop] and not @prev_values[prop]
		
		for prop in @props
			@prev_values[prop] = @[prop]
