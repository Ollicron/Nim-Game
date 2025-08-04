import 
    sdl2,
    game_types

# This proc toggles the designated value in the Input enum
proc toInput(key: Scancode): Input =
    case key
    of SDL_SCANCODE_A: Input.left
    of SDL_SCANCODE_D: Input.right
    of SDL_SCANCODE_SPACE: Input.jump
    of SDL_SCANCODE_R: Input.restart
    of SDL_SCANCODE_Q: Input.quit
    else: Input.none


# This proc is responsible for handling input events.
# it uses a scancode object when a key is pressed.
proc handleInput*(game: Game) =
    var event = defaultEvent
    while pollEvent(event):
        case event.kind
        of QuitEvent:
            game.inputs[Input.quit] = true
        of KeyDown:
            game.inputs[toInput(event.key.keysym.scancode)] = true
        of KeyUp:
            game.inputs[toInput(event.key.keysym.scancode)] = false
        else:
            discard



