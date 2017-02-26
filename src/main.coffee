
@world = new World()
layers = [
	# {scale: 0.5, world: new World()}
	# {scale: 0.7, world: new World()}
	{scale: 0.1, world: new World()}
	{scale: 0.2, world: new World()}
	{scale: 0.3, world: new World()}
	{scale: 0.4, world: new World()}
	{scale: 0.5, world: new World()}
	{scale: 0.6, world: new World()}
	{scale: 0.7, world: new World()}
	{scale: 0.8, world: new World()}
	# {scale: 0.99, world: new World()}
	{scale: 1, world}
	# {scale: 1.01, world: new World()}
]

view = {cx: 0, cy: 0, scale: 2, default_scale: 2, slowness: 8, zoom_slowness: 8}

paused = no
window.round_started = no
window.round_ending = no
window.round_over = no
remaining_countdown_seconds = 0

countdown_el = document.createElement("div")
document.body.appendChild(countdown_el)
countdown_el.classList.add("countdown")

round_end_el = document.createElement("div")
document.body.appendChild(round_end_el)
round_end_el.classList.add("round-end")

count_down = ->
	if remaining_countdown_seconds > 0
		countdown_el.classList.remove("now-fight")
		countdown_el.textContent = "#{remaining_countdown_seconds}..."
		remaining_countdown_seconds--
		# TODO: pause/unpause countdown
		setTimeout count_down, 1000
	else
		countdown_el.textContent = "FIGHT!"
		window.round_started = yes
		countdown_el.classList.add("now-fight")
	console.log countdown_el.textContent

init_round = ->
	window.round_started = false
	window.round_ending = false
	window.round_over = false
	round_end_el.textContent = ""
	
	# world.generate()
	for layer in layers
		layer.world.generate(bg: layer.scale isnt 1)
	
	remaining_countdown_seconds = if location.hash.match(/(quick|fast)( |-|)start/i) then 0 else 3
	count_down()

init_round()

animate ->
	return if loading
	world.step() unless paused
	{players} = world
	
	for player in players
		if player.y > 100
			player.dead = true
	
	live_players = (player for player in players when not player.dead)
	dead_players = (player for player in players when player.dead)
	
	if live_players.length <= 1
		unless window.round_ending
			window.round_ending = true
			setTimeout =>
				window.round_over = true
				setTimeout init_round, 1000
				round_end_el.style.color = ""
				if live_players[0]
					round_end_el.textContent = "#{live_players[0].name} wins!".toUpperCase()
					round_end_el.style.color = live_players[0].color
				else
					round_end_el.textContent = "Lethal draw!".toUpperCase()
				console.log "Round over!"
				console.log round_end_el.textContent
			, 1000
	
	# We keep dead players in view during the beat before the round is over
	# TODO: should probably keep only live and recently deceased players
	# in the case of more than two players; but this is probably a 2 player only game
	center_on_players =
		if live_players.length > 0 and (round_over or not round_ending)
		then live_players else players
	
	# TODO: don't just try to center players,
	# define and use level boundaries to make the view more useful
	move_view_to_cx = 0
	move_view_to_cy = 0
	for player in center_on_players
		move_view_to_cx += player.x
		move_view_to_cy += player.y
	move_view_to_cx /= center_on_players.length
	move_view_to_cy /= center_on_players.length
	
	# TODO: maybe replace this with some dynamic splitscreen; it doesn't really feel good
	# might not be so bad if there's some scenery for spacial awareness though
	player_view_margin_x = 300
	player_view_margin_y = 60
	view_scale_to = view.default_scale
	for player in center_on_players
		needed_scale_for_player = min(
			canvas.width / 2 / (abs(player.x - move_view_to_cx) + player_view_margin_x)
			canvas.height / 2 / (abs(player.y - move_view_to_cy) + player_view_margin_y)
		)
		view_scale_to = min(view_scale_to, needed_scale_for_player)
	
	move_view_to_cx = min(400*16 - canvas.width/2, max(-400*16 + canvas.width/2, move_view_to_cx))
	view.cx += (move_view_to_cx - view.cx) / view.slowness
	view.cy += (move_view_to_cy - view.cy) / view.slowness
	view.scale += (view_scale_to - view.scale) / view.zoom_slowness
	
	BG_FILL = "#a9bcd6"
	FOG = 1/2
	
	ctx.fillStyle = BG_FILL
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	
	for layer in layers
		ctx.save()
		ctx.globalAlpha = layer.scale * FOG
		ctx.fillStyle = BG_FILL
		ctx.fillRect(0, 0, canvas.width, canvas.height)
		ctx.restore()
		
		ctx.save()
		ctx.translate(canvas.width/2, canvas.height/2)
		ctx.scale(view.scale * layer.scale, view.scale * layer.scale)
		ctx.translate(-view.cx, -view.cy)
		layer.world.draw(ctx, view)
		ctx.restore()


pause = ->
	paused = yes
	document.body.classList.add "paused"

unpause = ->
	paused = no
	document.body.classList.remove "paused"

toggle_pause = ->
	if paused then unpause() else pause()

window.addEventListener "keydown", (e)->
	console.log e.keyCode if e.altKey
	if e.keyCode is 80 # P
		toggle_pause()
