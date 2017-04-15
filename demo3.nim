import random

import sdl2
import sdl2.ttf

import dadren.application
import dadren.scenes

import ./simpleton


# tuple rects to c rects
converter intRect2cintRect(t: tuple[x, y, w, h: int]):
    sdl2.Rect = (t.x.cint, t.y.cint, t.w.cint, t.h.cint)

# tuple color to c color
converter intColor2uint8Color(t: tuple[r, g, b, a: int]):
    sdl2.Color = (t.r.uint8, t.g.uint8, t.b.uint8, t.a.uint8)


type
    TextureObj = object
        data: sdl2.TexturePtr
        rect: sdl2.Rect

    Texture = ref TextureObj


proc render_text(font: ttf.FontPtr, display: sdl2.RendererPtr, text: string, color: sdl2.Color): Texture =
    new(result)

    let surf = font.renderUtf8Blended(cstring(text), color)
    var w, h: cint

    result.data = display.createTextureFromSurface(surf)
    result.data.queryTexture(nil, nil, addr w, addr h)
    result.rect = (cint(0), cint(0), w, h)


type
    ColorWidget = ref object of simpleton.SimpletonWidget
        color: sdl2.Color
        app: App

    ColorClickyWidget = ref object of ColorWidget

    ColorTextWidget = ref object of ColorWidget
        texture: Texture

proc newColorWidget(app: App, rect: sdl2.Rect): ColorWidget =
    new(result)
    result.rect = rect
    result.color = (0, 0, 255, 255)
    result.app = app

proc newColorTextWidget(app: App, rect: sdl2.Rect, text: string, font: ttf.FontPtr): ColorTextWidget =
    new(result)
    result.rect = rect
    result.color = (0, 255, 0, 255)
    result.app = app
    result.texture = font.render_text(app.display, text, (0, 0, 0, 255))

proc newColorClickyWidget(app: App, rect: sdl2.Rect): ColorClickyWidget =
    new(result)
    result.rect = rect
    result.color = (255, 0, 0, 255)
    result.app = app

method draw(self: ColorWidget, rect: sdl2.Rect) =
    self.app.display.setDrawColor(self.color)
    var rect = rect
    self.app.display.fillRect(addr rect)


method draw(self: ColorTextWidget, rect: sdl2.Rect) =
    self.app.display.setDrawColor(self.color)
    var rect = rect
    self.app.display.fillRect(addr rect)

    rect = rect.center_subrect(self.texture.rect)
    self.app.display.copy(self.texture.data, nil, addr rect)


method on_click(self: ColorClickyWidget, event: sdl2.Event, point: simpleton.Point): bool =
    echo $point

    var r, g, b = 0

    while r + g + b < 150:
        r = random(256)
        g = random(256)
        b = random(256)

    self.color = (r, g, b, 255)

    return true


type
    Pos = tuple[x, y: int]

    GameScene = ref object of Scene
        app: App
        ui: simpleton.SimpletonUI


proc newGameScene(app: App): GameScene =
    new(result)

    result.app = app

    let
        positions: seq[Pos] = @[
            (0, 0),
            (600, 0),
            (0, 400),
            (600, 400)
        ]
        ui_rect: sdl2.Rect = (0, 0, 1000, 600)
        font = openFont(cstring("Bandal.ttf"), cint(40))

    var
        w_rect: sdl2.Rect
        widgets: seq[SimpletonWidget] = @[]


    for i, pos in pairs(positions):
        w_rect = (pos.x, pos.y, 400, 200)
        case i:
            of 0: widgets.add(newColorWidget(app, w_rect))
            of 1,2: widgets.add(newColorClickyWidget(app, w_rect))
            of 3: widgets.add(newColorTextWidget(app, w_rect, "Unclickable!", font))
            else: discard

    result.ui = newSimpletonUI(ui_rect, @[newSimpletonLayer(ui_rect, widgets)])


method handle(self: GameScene, event: sdl2.Event) =
    self.ui.dispatch(event)

method draw(self: GameScene) =
    self.app.clear(0, 0, 0)
    self.ui.draw()


when isMainModule:
    ttfInit()
    let
        app = newApp("demo3.json")
        scene = newGameScene(app)

    scene.draw()
    app.run(scene)
