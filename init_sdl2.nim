import 
    sdl2, sdl2/image,
    game_types,
    render_sprite,
    render_map,
    user_input,
    game_physics,
    times,
    basic2d


# Constants
const imgFlags: cint = IMG_INIT_PNG
type SDLEXCEPTION = object of CatchableError

template sdlFailIf(cond: typed, reason: string) =
    if cond: 
        raise SDLEXCEPTION.newException(
            reason & ", SDL error: " & $getError()
        )

# Forward declarations
proc render(someGame: Game)

# Initialize everything
proc init*: (RendererPtr, WindowPtr) =

    sdlFailIf(not sdl2.init(INIT_VIDEO or INIT_TIMER or INIT_EVENTS)):
        "SDL2 initialization failed"
    
    # Check if subsystems were initialized
    var subCheck:uint32 = sdl2.wasInit(INIT_VIDEO or INIT_TIMER or INIT_EVENTS)
    if subCheck > 0:
        echo "All necessary subsystems initialized"

    sdlFailIf(not setHint("SDL_RENDER_SCALE_QUALITY", "2")):
        "Linear texture filtering could not be enabled"

    # Create the window
    let window = createWindow(
        title = "Our 2D Platformer",
        x = SDL_WINDOWPOS_CENTERED,
        y = SDL_WINDOWPOS_CENTERED,
        w = 1280, h = 720, 
        flags = SDL_WINDOW_SHOWN
    )

    sdlFailIf(window.isNil, "Window could not be created")

    # Create the renderer
    let renderer = window.createRenderer(
        index = -1,
        flags = Renderer_Accelerated or Renderer_PresentVsync,
    )

    sdlFailIf(renderer.isNil, "Renderer could not be created")

    # Set the default color to use for drawing
    renderer.setDrawColor(r = 110, g = 132, b = 174)

    # Initialize the image module 
    sdlFailIf(image.init(imgFlags) != imgFlags):
        "SDL2 Image initialization failed"

    return (renderer,window)


# Procedure to create a new Game object after we have our renderer set
proc newGame*(someRenderer: RendererPtr): Game =
    # Creates a new Game object on the heap out using result var with a renderer and a player
    new result
    result.renderer = someRenderer
    result.player = render_sprite.newPlayer(someRenderer.loadTexture(
        "Assets/Popo-AnimationSheet.png"))
    result.map = newMap(someRenderer.loadTexture("Assets/grass.png"),
        "Assets/default.map")
    result.background = someRenderer.loadTexture("Assets/mountains.jpg")


# Procedure to start the game after everything is initialized and Game object is created
proc start*(someGame: Game) =
    
    # Game loop, draws each frame
    while not someGame.inputs[Input.quit]:

        if someGame.inputs[Input.restart]:
            restartPlayer(someGame.player)

        # We want to detect collision before any tick event
        someGame.player.collisions = determineCollision(someGame)

        # Handle the inputs
        someGame.handleInput()

        #[ 
        The tick requires a greater deal of explanation. The first step is understanding the nature of epochTime(). epochTime() gets the current time since epoch. The while loop performs one iteration and then subtracts it from the amount of time since the inception of the game(startTime).

        From a frame of reference, we are assuming in this example we want 1 tick per second.

        Knowing this, if one where to echo out the difference it would run through this loop but look like the value is updating every second. To simplify things, we create the integer from it to avoid the decimal value.

        Then expectedTicks is effectively updating every second. One can say the tick is a slice of time but that is not the case.

        A tick is better described as when your code decides to execute critical logic. What does this mean? It means a tick is when we the programmer tell the program to execute some logic.

        In this case we want this logic happening 50 times, giving us (1s)x(50 ticks/s) = 50 ticks. In an example of say 36 seconds into the program running, we get 36s*50ticks = 1800 (ticks*s), and the value before 35s* 50 ticks = 1750 ticks * s... Eventually that 1750 value becomes 1800 and we stop and skip over the loop. This gives the illusion of delay.

        expectedTicks is the total number of ticks that are expected to have happened.totalRanTicks is the number of ticks that have already passed. As long as this value is less than the expectedTicks we simulate physics.
        ]#

        let expectedTicks = int((epochTime()-game_physics.startTime) * 50)
        #echo epochTime()-game_physics.startTime
        if totalExecutedTicks < expectedTicks:
            # We want this executed 50 times between one second

            someGame.simulatePhysics(someGame.player.collisions)
        totalExecutedTicks = expectedTicks

        # render everything
        someGame.render()

# Procedure to render stuff
proc render(someGame: Game) =
    # Draw over all drawings of the last frame with default color
    someGame.renderer.clear()

    # Draw the mountains
    someGame.renderer.copy(someGame.background,nil,nil)

    # Draw our character
    someGame.renderer.renderSprite(someGame.player.texture, 
        someGame.player.pos - someGame.camera)

    # Draw our map
    someGame.renderer.renderMap(someGame.map,someGame.camera)

    # Show result on screen
    someGame.renderer.present()