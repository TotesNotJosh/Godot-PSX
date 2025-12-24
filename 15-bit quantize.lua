----------------------------------------------------------------------
-- Set the image pixels to a 15-bit value.
--
-- It works for RGB color mode only.
----------------------------------------------------------------------

if app.apiVersion < 1 then
  return app.alert("This script requires Aseprite v1")
end

local cel = app.activeCel
if not cel then
  return app.alert("There is no active image")
end

local img = cel.image:clone()

if img.colorMode == ColorMode.RGB then
  local rgba = app.pixelColor.rgba
  local rgbaA = app.pixelColor.rgbaA
  for it in img:pixels() do
    local pixelValue = it()
    local r = math.floor(app.pixelColor.rgbaR(pixelValue)/8)*8
    local g = math.floor(app.pixelColor.rgbaG(pixelValue)/8)*8
    local b = math.floor(app.pixelColor.rgbaB(pixelValue)/8)*8
    it(rgba(r,
            g,
            b, rgbaA(it())))
  end
end

cel.image = img

app.refresh()
