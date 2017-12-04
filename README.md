# [<img alt="Delayed Casualty" src="./images/title/title-readme.png" height="125">](http://1j01.github.io/delayed-casualty/)

A swordfighting game with simple but unique mechanics.

There are no combos to memorize.  
There are no meters.  
You don't have to face the other player,
except in the sense that you're dueling.

You can attack and parry.  
One hit kills.  
But who dies?

If you fail to either block or attack back, naturally you die.  
<!-- And if you block, you'll survive, but your sword will be damaged.   -->
But if both players connect and attack in a clash, one will win based on...

1. Timing: you want to hit as soon as your opponent comes within your swing radius.
2. Angle: you want to be higher up than your opponent.
3. Speed: you want to be moving faster than your opponent.
<!-- 4. potentially, character attributes that affect the amounts that the above factor in -->

## Controls

Currently the controls are hard-coded but
[I have plans for a library for input configuration with UI and such.](https://github.com/multiism/input-control)

| Action    | Player 1  | Player 2      | Player 2 (Gamepad)                    |
|-----------|-----------|---------------|---------------------------------------|
| Left      | Left      | D / L         | D-pad left / left analog stick left   |
| Right     | Right     | A / J         | D-pad right / left analog stick right |
| Jump      | Up        | W / I / Space | Some face button                      |
| Descend   | Down      | S / K         | D-pad down                            |
| Attack    | .         | G             | R1 / R2 / Some face button            |
| Block     | /         | H             | L1 / L2 / Some face button            |
| Genuflect | Shift / Z | Ctrl          | Some face button                      |

Wall movement:

* Press away from the wall to do a long jump
* Press up to do a high jump (still kicking away from the wall)
* Press up and away to jump up and away more
* Hold up and towards the wall to wall-climb
* Hold down to fall downwards

Air movement:

* Continue holding up after jumping to jump higher
* More generally, hold up to reduce your gravity
* You can move adjust your horizontal velocity somewhat too
* TODO: Press down to reduce horizontal velocity towards zero to land on platforms easier

