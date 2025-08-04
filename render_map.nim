import 
    sdl2,
    game_types,
    basic2d,
    std/strutils

const
    tilesPerRow = 16
    tileSize: Point = (64.cint, 64.cint)

# The purpose of this function is to generate a new Map object
# It is placed inside a Game object
proc newMap*(texture:TexturePtr, file:string): Map =
    # A map has a texture, width, height, and a sequence of tiles
    new result
    result.texture = texture
    var 
        i:uint8 = 0

    var row = 0
    for line in file.lines:
        var col = 0
        for word in line.split(' '):
            if word.len == 0: continue
            result.mapMatrix[row][col] = uint8(parseUInt(word))
            inc col
        inc row


proc renderMap*(renderer: RendererPtr, map: Map, camera: Vector2d)=
    # Here we need to figure out how to get the cutouts from the PNG into rendering the entire map
    var
        clip = rect(0, 0, tileSize.x, tileSize.y)
        dest = rect(0, 0, tileSize.x, tileSize.y) 

    var i = 0 
    for row in 0 .. mapHeight-1:
        for col in 0 .. mapWidth-1:
            inc(i)
            let tileNr = int(map.mapMatrix[row][col])
            if tileNr == 0:
                continue    
            clip.x = cint(tileNr mod tilesPerRow) * tileSize.x 
            clip.y = cint(tileNr div tilesPerRow) * tileSize.y
            dest.x = (cint(i mod mapWidth)+cint(0)) * tileSize.x - camera.x.cint
            dest.y = (cint(i div mapWidth)+cint(0)) * tileSize.y - camera.y.cint

            renderer.copy(map.texture, unsafeAddr clip, unsafeAddr dest)
