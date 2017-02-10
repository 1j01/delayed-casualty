
class @Ground extends Entity
	constructor: ->
		@x ?= 16 * -400
		@w ?= 16 * 800
		@h ?= 16
		super
	
	draw: (ctx, view)->
		ctx.fillStyle = "#000"
		ctx.fillRect @x, @y, @w, @h
