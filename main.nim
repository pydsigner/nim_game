import random

import sdl2

import dadren.application
import dadren.scenes


# treat uint8 as bool
converter uint82bool(x: uint8):
    bool = bool(x)

# native rects to c rects
converter intRect2cintRect(t: tuple[x, y, w, h: int]):
    sdl2.Rect = (t.x.cint, t.y.cint, t.w.cint,t.h.cint)

# tuple color to c color
converter intColor2uint8Color(t: tuple[r, g, b, a: int]):
    sdl2.Color = (t.r.uint8, t.g.uint8, t.b.uint8, t.a.uint8)


type
    GameScene = ref object of Scene
        app: App

        location: tuple[x, y: int]
        color: sdl2.Color

proc newGameScene(app: App): GameScene =
    new(result)
    result.location = (10, 10)
    result.color = (255, 0, 0, 255)

    result.app = app


proc randomize_color(self: GameScene) =
    var total = 0
    var r, g, b: int
    while total < 150:
        r = random(256)
        b = random(256)
        g = random(256)
        total = r + b + g
    self.color = (r, g, b, 255)

proc handle_key(self: GameScene, keysym: sdl2.KeySym) =
    # event-based input handling
    case keysym.sym:
      of K_LEFT: discard
      of K_RIGHT: discard
      of K_UP: discard
      of K_DOWN: discard
      of K_SPACE:
          self.randomize_color()
      else: discard


method update(self: GameScene, t, dt: float) =
    # continuous per-frame input handling
    let keys = getKeyboardState()

    if keys[SDL_SCANCODE_LEFT.cint]:
        self.location = (self.location.x - 1, self.location.y)
    elif keys[SDL_SCANCODE_RIGHT.cint]:
        self.location = (self.location.x + 1, self.location.y)
    if keys[SDL_SCANCODE_UP.cint]:
        discard
    elif keys[SDL_SCANCODE_DOWN.cint]:
        discard

method handle(self: GameScene, event: sdl2.Event) =
    case event.kind:
        of KeyDown:
            self.handle_key(event.key.keysym)
        else: discard

method draw(self: GameScene) =
    self.app.clear(0, 0, 0)
    self.app.display.setDrawColor(self.color)
    var r: sdl2.Rect = (self.location.x, self.location.y, 10, 10)
    self.app.display.drawRect(addr r)


let
    app = newApp("settings.json")
    scene = newGameScene(app)

scene.draw()
app.run(scene)
