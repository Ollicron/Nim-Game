import 
    sdl2,sdl2/image,
    init_sdl2

proc main =
    let (renderer,window) = init_sdl2.init()
    defer: renderer.destroy()
    defer: window.destroy()
    defer: sdl2.quit()
    defer: image.quit()

    let game = init_sdl2.newGame(renderer)
    init_sdl2.start(game)

main()