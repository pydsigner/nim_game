import random

import sdl2

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
    ColorClickyWidget = ref object of simpleton.SimpletonWidget
        color: sdl2.Color
        app: App

proc newWidget(app: App, rect: sdl2.Rect): ColorClickyWidget =
    new(result)
    result.rect = rect
    result.color = (255, 0, 0, 255)
    result.app = app

method draw(self: ColorClickyWidget, rect: sdl2.Rect) =
    self.app.display.setDrawColor(self.color)
    var r = rect
    self.app.display.drawRect(addr r)

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

    var
        ui_rect: sdl2.Rect = (0, 0, 500, 300)
        widgets: seq[SimpletonWidget] = @[]
        positions: seq[Pos] = @[
            (0, 0),
            (100, 0),
            (0, 200),
            (300, 200)
         ]

    for pos in positions:
        widgets.add(newWidget(app, (pos.x, pos.y, 200, 100)))

    result.ui = newSimpletonUI(ui_rect, @[newSimpletonLayer(ui_rect, widgets)])


method handle(self: GameScene, event: sdl2.Event) =
    self.ui.dispatch(event)

method draw(self: GameScene) =
    self.app.clear(0, 0, 0)
    self.ui.draw()


when isMainModule:
    let
        app = newApp("demo2.json")
        scene = newGameScene(app)

    scene.draw()
    app.run(scene)
