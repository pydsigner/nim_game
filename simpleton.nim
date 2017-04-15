import sdl2


type
    Point* = tuple[x, y: int32]


proc contains_point*(rect: sdl2.Rect, point: Point): bool =
    return ((point.x >= rect.x) and (point.x < (rect.x + rect.w)) and
            (point.y >= rect.y) and (point.y < (rect.y + rect.h)))

proc normalize_point*(rect: sdl2.Rect, point: Point): Point =
    return (x: point.x + int32(rect.x),
            y: point.y + int32(rect.y))

proc normalize_subrect*(parent, child: sdl2.Rect): sdl2.Rect =
    return (x: parent.x + child.x,
            y: parent.y + child.y,
            w: min(child.w, parent.w - child.x),
            h: min(child.h, parent.h - child.y))

proc center_subrect*(parent, child: sdl2.Rect): sdl2.Rect =
    return (x: parent.x + cint((parent.w - child.w) / 2),
            y: parent.y + cint((parent.h - child.h) / 2),
            w: child.w,
            h: child.h)


type
    SimpletonWidget* = ref object of RootObj
        rect*: sdl2.Rect

    SimpletonLayerObj* = object
        visible: bool
        rect: sdl2.Rect
        widgets: seq[SimpletonWidget]

    SimpletonLayer* = ref SimpletonLayerObj

    SimpletonUIObj* = object
        rect: sdl2.Rect
        layers: seq[SimpletonLayer]

    SimpletonUI* = ref SimpletonUIObj


proc newSimpletonLayer*(rect: sdl2.Rect, widgets: seq[SimpletonWidget], visible = true): SimpletonLayer =
    new(result)
    result.visible = visible
    result.rect = rect
    result.widgets = widgets


proc newSimpletonUI*(rect: sdl2.Rect, layers: seq[SimpletonLayer]): SimpletonUI =
    new(result)
    result.rect = rect
    result.layers = layers


method draw*(self: SimpletonWidget, rect: sdl2.Rect) {.base.} = discard
method on_click*(self: SimpletonWidget, event: sdl2.Event, point: Point): bool {.base.} = return false


proc draw(self: SimpletonLayer, rect: sdl2.Rect) =
    for widget in self.widgets:
        widget.draw(rect.normalize_subrect(widget.rect))

proc dispatch(self: SimpletonLayer, event: sdl2.Event, point: Point): bool =
    var handled = false

    for widget in self.widgets:
        if widget.rect.contains_point(point):
            handled = widget.on_click(event, widget.rect.normalize_point(point)) or handled


proc draw*(self: SimpletonUI) =
    for layer in self.layers:
        if layer.visible:
            layer.draw(self.rect.normalize_subrect(layer.rect))

proc dispatch*(self: SimpletonUI, event: sdl2.Event) =
    if event.kind != MouseButtonDown:
        return

    var
        handled = false
        point: Point = self.rect.normalize_point((event.button.x, event.button.y))

    for layer in self.layers:
        if layer.visible and layer.rect.contains_point(point):
            handled = layer.dispatch(event, layer.rect.normalize_point(point))

            if handled: break
