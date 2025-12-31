--==================================================
-- Creates a color slider for 15-bit.
--
-- It works for RGB color mode only.
--==================================================
if app.apiVersion < 1 then
    return app.alert("This script requires Aseprite v1")
end

local picker = Dialog("15-bit RGB Picker")
local updating = false
local r, g, b = 0, 0, 0

local function quantize(v)
    return math.floor(v / 8) * 8
end

local function updateFGColor()
    r = picker.data.r
    g = picker.data.g
    b = picker.data.b
    if r == 256 then
        r = 255
    end
    if g == 256 then
        g = 255
    end
    if b == 256 then
        b = 255
    end
    app.fgColor = Color {
        r = r,
        g = g,
        b = b
    }
end

local function updateBGColor()
    r = picker.data.r
    g = picker.data.g
    b = picker.data.b
    if r == 256 then
        r = 255
    end
    if g == 256 then
        g = 255
    end
    if b == 256 then
        b = 255
    end
    app.bgColor = Color {
        r = r,
        g = g,
        b = b
    }
end

local function updatePreview()
    local roy = picker.data.r
    local gee = picker.data.g
    local biv = picker.data.b
    if roy == 256 then
        roy = 255
    end
    if gee == 256 then
        gee = 255
    end
    if biv == 256 then
        biv = 255
    end
    picker:modify{
        id = "preview",
        color = Color {
            r = roy,
            g = gee,
            b = biv
        }
    }
end

local function snapSlider(id)
    if updating then
        return
    end
    updating = true
    local v = math.floor(picker.data[id] / 8) * 8
    picker:modify{
        id = id,
        value = v
    }
    updatePreview()
    updating = false
end

picker:slider{
    id = "r",
    label = "Red",
    min = 0,
    max = 256,
    value = 0,
    onchange = function()
        snapSlider("r")
    end
}:slider{
    id = "g",
    label = "Green",
    min = 0,
    max = 256,
    value = 0,
    onchange = function()
        snapSlider("g")
    end
}:slider{
    id = "b",
    label = "Blue",
    min = 0,
    max = 256,
    value = 0,
    onchange = function()
        snapSlider("b")
    end
}:color{
    id = "preview",
    label = "Preview",
    color = Color {
        r = 0,
        g = 0,
        b = 0
    }
}:button{
    text = "FG Color",
    onclick = function()
        updateFGColor()
    end
}:button{
    text = "BG Color",
    onclick = function()
        updateBGColor()
    end
}:button{
    text = "Close",
    onclick = function()
        picker:close()
    end
}

picker:show{
    wait = false
}
