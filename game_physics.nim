import 
  times,
  basic2d,
  game_types


var
    startTime* = epochTime()
    totalExecutedTicks* = 0

proc simulatePhysics*(game: Game, collisionCheck: collisionBools)=
    # if the bot collision is true then jumping and walking l/r is allowed
    if collisionCheck.botCol == true:
        game.player.vel.y = 0
        # When a player jumps there is no acceleration it's a constant speed.
        if game.inputs[Input.jump]:
            game.player.vel.y = -21

    else:
        # Otherwise Gravity takes effect

        # By default the velocity keeps increasing, we set it here to 0.75, so each iteration it looks like acceleration.
        game.player.vel.y += 0.75

    # This becomes 1.0, 0.0, or -1.0
    let direction = float(game.inputs[Input.right].int -
                        game.inputs[Input.left].int)

    if collisionCheck.sideColRight == true and direction > 0:
        game.player.vel.x = 0
    elif collisionCheck.sideColLeft == true and direction < 0:
        game.player.vel.x = 0
    else:
        # When a player presses right or left we want to clamp the values so that velocity does not go over a certain amount, we also need a direction
        game.player.vel.x = clamp(
        0.5 * game.player.vel.x + 4.0 * direction, -8, 8)

    
    game.player.pos += game.player.vel




# This procedure is used to determine collision from a map matrix
proc determineCollision*(game:Game):collisionBools=

    # The sprite has a tile size, but we need to make sure that 
    # if it touches any area where there's a solid, that it stops.

    var collisionBooleans:collisionBools

    # First we need to grab the player's current coordinates
    var playerPos = game.player.pos

    # Next we need to find the lower point of the player tile
    # but add 64 to that because we want one tile length below it.
    var playerLow = Point2d(x:playerPos.x, y:playerPos.y + 64)

    # We also need the sides of the player
    var playerSides = Point2d(x: playerPos.x-64,y: playerPos.x)

    # Next if we need the tile location of this playerLow position (if there is one)
    var tileColBot = (int(playerLow.x) div 64)
    var tileRowBot = (int(playerLow.y) div 64)

    # Do the same for the sides 
    var tileLeftCol = int(playerSides.x) div 64
    var tileRightCol = int(playerSides.y) div 64

    # We first check the bottom there's a tile, we set collision to true
    if game.map.mapMatrix[tileRowBot][tileColBot] > 0:
        collisionBooleans.botCol = true
    else:
        collisionBooleans.botCol = false

    # Next we check the Right, we know that the y is the same as playerpos so we use that
    var tileRightRow = int(playerPos.y) div 64
    var tileLeftRow = int(playerPos.y) div 64
    if game.map.mapMatrix[tileRightRow][tileRightCol] > 0:
        collisionBooleans.sideColRight = true
    else:
        collisionBooleans.sideColRight = false

    if game.map.mapMatrix[tileLeftRow][tileLeftCol] > 0:
        collisionBooleans.sideColLeft = true
    else:
        collisionBooleans.sideColLeft = false

    return collisionBooleans

