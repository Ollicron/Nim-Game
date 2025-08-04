import 
    sdl2,
    basic2d,
    game_types

type
    Box = tuple
        src: Rect
        dst: Rect
        flip: cint

#[This sets the player position, we've set the location to be 100,300px from the top left corner]#
proc restartPlayer*(player: Player) =
    player.pos = point2d(200,300)
    player.vel = vector2d(0,0)

proc newPlayer*(texture: TexturePtr): Player =
    new result
    result.texture = texture
    result.restartPlayer()

proc renderSprite*(renderer: RendererPtr, texture: TexturePtr, pos: Point2d)=
    let 
        x = pos.x.cint
        y = pos.y.cint

    var popoSupercat: Box
    
    # Get the number of half seconds 
    var timeSinceStart = (cast[int](getTicks())/1000)*6
    
    # Determine what frame the box should be on  using seconds since start
    # by modulus 10 to determine what are on
    var frame = int(timeSinceStart) mod 10

    popoSupercat = (src:rect(cint(frame*64), 0, 64, 48), dst:rect(x,y, 64,64), flip:SDL_FLIP_NONE)

    renderer.copyEx(texture, popoSupercat.src, popoSupercat.dst, angle = 0.0, 
        center = nil, flip = popoSupercat.flip )