
class @NPC extends Character
	constructor: ->
		super
		@controller = new NPCBrain(iq: 50)
