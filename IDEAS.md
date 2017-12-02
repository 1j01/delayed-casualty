
# brainstorming document

Note: screenshots already leaked here: http://tvtropes.org/pmwiki/pmwiki.php/Main/SingleStrokeBattle

## Movement

* Input
	* [A library for gamepad and keyboard input assignment and remapping, including UI](https://github.com/multiism/input-control)
	* Allow early inputs where appropriate

* Press down to land on platforms easier
	* Head towards zero velocity in air
	* Don't fall off ledges
	* Maybe holding left and right could do this too, or... would that just be confusing?

* Going down walls
	* Remove wall-slipping (just stick to walls)
	* Add friction when wall-dropping (or it would be "descending", rather; and would it be necessary then?)

* Ledge grabbing (you can climb up a ledge but it's easy to overshoot the platform)


## Fighting

* Clash outcomes
	* WIN/LOSE
		* one player fails to attack or block
		* one player wins the power contest
	* DRAW
		* a player successfully blocks
		* both players block
	* LETHAL DRAW
		* both players attack with (approximately) the same hit power
		* both players block and BOTH swords break

* Special match outcomes
	* WIN/LOSE
		* a player falls into an abyss
	* DRAW
		* time runs out
	* LETHAL DRAW
		* both players fall into an abyss

If the match is a draw,
there can be a sudden death final standoff/JUMPoff more like it HEH,
with the jumping and the slice-a-dicing and not so much of the blocking.

* Blocking should damage your sword based on how well you blocked vs their attack, with a minimum damage,
  and blocking should simply always work as long as you don't miss and your sword is intact.

* Maybe you should be able to hold down block beforehand rather than timing it,
  which would be more reliable but would damage your sword by the full amount.

* Maybe the timing for blocking could be based on when the other player attacks?

* Make outcomes more predictable at close range
	* by weighting the height advantage less at closer range 
	* or maybe making the height advantage more linear or exponential or logarithmic instead of angular

* Use rendered player for hit detection, or at least have a better hitbox

* Scarves/hair/capes/cloaks/whatever get cut off, and then five seconds later... shloomp, off goes the head

* Indicate 50% & 25% sword health audio-visually
AND ALSO 0% because that's kind of important


## Characters (maybe)

Like Lethal League does really well,
the characters might seem aesthetic at first,
but as you play with them you start to notice significant differences.

* characters
	* eh, maybe no characters
	* two hit wonder
		* two swords
		* average power higher for two successful hits, lower for one
		* due to delay, you generally have to hit on both sides of the circle of attack to be effective
		* Braggro - Mesas & cliffs of red clay
	* bamboozler
		* wields reed staff (not bamboo)
		* staff can be cut off at one or two points, so very little durability
		* could be dynamic, being cut off based on the attacker's distance, which should encourage... keeping a distance?
		* low damage probably
		* Yeccalio - cold icy miserable salt marsh
	* knife guy
		* really shit swing radius
		* is there any reason this should exist?
		* yes
		* to show how pro u are
		* can block indefinitely
		* Yeccalio - warm open field
	* bird guy
		* can slow himself down in the air (very well)
		* does he glide when he does that?
		* just better air control in general
		* bird motif, not part bird
		* thin sharp razor sword
		* Seslo - island nation, coastal, steep cliffs
	* big guy
		* big sword
		* good block, long delay?

* character packs
	* lethal league crossover
	* dank memes collection


## Misc

* Global timescale
	* For development, seeing animations and behavior in detail
	* Option for custom matches

* Round timer

* Dissuade/limit strategy of running out the clock (esp. for best-of matches)

* Screens
	* Title
	* Pause
	* Settings
		* Controls
		* SFX volume
		* Music volume
	* Credits

* Anticipate collision with wall for animation
