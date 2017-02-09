
@world = new World()

view = {cx: 0, cy: 0, scale: 2, default_scale: 2, slowness: 8, zoom_slowness: 8}

paused = no
window.round_started = no
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
		setTimeout count_down, 1000
	else
		countdown_el.textContent = "FIGHT!"
		window.round_started = yes
		countdown_el.classList.add("now-fight")
	console.log countdown_el.textContent

init_round = ->
	window.round_started = false
	window.round_over = false
	round_end_el.textContent = ""
	
	world.generate()
	remaining_countdown_seconds = if location.hash.match(/(quick|fast)( |-|)start/i) then 0 else 3
	count_down()

init_round()

animate ->
	return if loading
	world.step() unless paused
	{players} = world
	
	# TODO: don't just try to center players,
	# define and use level boundaries to make the view more useful
	move_view_to_cx = 0
	move_view_to_cy = 0
	for player in players
		move_view_to_cx += player.x
		move_view_to_cy += player.y
	move_view_to_cx /= players.length
	move_view_to_cy /= players.length
	
	# TODO: maybe replace this with some dynamic splitscreen; it doesn't really feel good
	# might not be so bad if there's some scenery for spacial awareness though
	keep_players_in_view_x = 120
	keep_players_in_view_y = 60
	view_scale_to = view.default_scale
	for player in players
		needed_scale_for_player = min(
			canvas.width / 2 / (abs(player.x - move_view_to_cx) + keep_players_in_view_x)
			canvas.height / 2 / (abs(player.y - move_view_to_cy) + keep_players_in_view_y)
		)
		view_scale_to = min(view_scale_to, needed_scale_for_player)
	
	move_view_to_cx = min(400*16 - canvas.width/2, max(-400*16 + canvas.width/2, move_view_to_cx)) # https://github.com/atom/language-coffee-script/issues/112
	view.cx += (move_view_to_cx - view.cx) / view.slowness
	view.cy += (move_view_to_cy - view.cy) / view.slowness
	view.scale += (view_scale_to - view.scale) / view.zoom_slowness
	
	ctx.fillStyle = "#a9bcd6"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	
	ctx.save()
	ctx.translate(canvas.width/2, canvas.height/2)
	ctx.scale(view.scale, view.scale)
	ctx.translate(-view.cx, -view.cy)
	world.draw(ctx, view)
	ctx.restore()
	
	for player in players
		if player.y > 100
			player.dead = true
	
	live_players = (player for player in players when not player.dead)
	dead_players = (player for player in players when player.dead)
	
	if live_players.length <= 1
		# TODO: there should probably be a beat before the round ends
		# so you can pay attention to the ridiculous death animation
		# and if there's going to be other ways to die than by a living player,
		# so we have a time to determine if both players are gonna die
		unless window.round_over
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
