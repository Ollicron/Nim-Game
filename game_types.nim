import
    sdl2,
    basic2d

#global constants for map rendering
const mapWidth*:int = 20
const mapHeight*:int = 12

type
    Input* {.pure.} = enum none, left, right, jump, restart, quit


    Map* = ref object
        texture*: TexturePtr
        width*, height*: int
        # A map will contain a sequence from the input .map file.
        mapMatrix*: array[mapHeight,array[mapWidth,uint]]

    collisionBools* = tuple
        sideColLeft:bool
        sideColRight:bool
        botCol:bool

    Player* = ref object
        texture*: TexturePtr
        pos*: Point2d
        vel*: Vector2d
        collisions*:collisionBools

    # A game is supposed to have a renderer, a player, a map, and a camera 
    Game* = ref object
        inputs*: array[Input, bool]
        renderer*: RendererPtr
        player*: Player
        camera*: Vector2d
        map*: Map
        background*: TexturePtr