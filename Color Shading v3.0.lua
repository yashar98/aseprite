-- Color Shading v3.0
-- Aseprite Script that opens a dynamic palette picker window with relevant color shading options
-- Written by Dominick John, twitter @dominickjohn
-- Contributed to by David Capello
-- https://github.com/dominickjohn/aseprite/

-- Update v3.0 Notes:
-- in this version the overall logic of the code changed for fixing bugs
-- and added new functionality for auto pick colors.

-- Instructions:
--    Place this file into the Aseprite scripts folder (File -> Scripts -> Open Scripts Folder)
--    Run the "Color Shading" script (File -> Scripts -> Color Shading) to open the palette window.

-- Commands:
--    Base: Clicking on either base color will switch the shading palette to that saved color base.
--    "Get" Button: Updates base colors using the current foreground and background color and regenerates shading.
--    Left click: Set clicked color as foreground color.
--    Right click: Set clicked color as background color.
--    Middle click: Set clicked color as foreground color and regenerate all shades based on this new color.
--    Auto Pick checkbox: for detect picking color with eyedropper and color palette.

-- Note:
--    If you whant change the Right Click functionality whit Middle click (like PyxelEdit)
--    just swap the code between two else if statement in line 206 and 210.


-- variables -------------------------------------------------------------------------

-- main variables
local dlg
local autoPick = true;
local fgListenerCode;
local bgListenerCode;
local eyeDropper = true;

-- BG AND FG COLORS
local FGcache;
local BGcache;

-- CORE COLOR
local coreColor

-- SHADING COLORS
local S1;
local S2;
local S3;
local S5;
local S6;
local S7;

-- LIGHTNESS COLORS
local L1;
local L2;
local L3;
local L5;
local L6;
local L7;

-- SATURATION COLORS
local C1;
local C2;
local C3;
local C5;
local C6;
local C7;

-- HUE COLORS
local H1;
local H2;
local H3;
local H5;
local H6;
local H7;

-- main functions ------------------------------------------------------------------
local function lerp(first, second, by)
  return first * (1 - by) + second * by
end

local function lerpRGBInt(color1, color2, amount)
  local X1 = 1 - amount
  local X2 = color1 >> 24 & 255
  local X3 = color1 >> 16 & 255
  local X4 = color1 >> 8 & 255
  local X5 = color1 & 255
  local X6 = color2 >> 24 & 255
  local X7 = color2 >> 16 & 255
  local X8 = color2 >> 8 & 255
  local X9 = color2 & 255
  local X10 = X2 * X1 + X6 * amount
  local X11 = X3 * X1 + X7 * amount
  local X12 = X4 * X1 + X8 * amount
  local X13 = X5 * X1 + X9 * amount
  return X10 << 24 | X11 << 16 | X12 << 8 | X13
end

local function colorToInt(color)
  return (color.red << 16) + (color.green << 8) + (color.blue)
end

local function colorShift(color, hueShift, satShift, lightShift, shadeShift)
  local newColor = Color(color) -- Make a copy of the color so we don't modify the parameter

  -- SHIFT HUE
  newColor.hslHue = (newColor.hslHue + hueShift * 360) % 360

  -- SHIFT SATURATION
  if (satShift > 0) then
    newColor.saturation = lerp(newColor.saturation, 1, satShift)
  elseif (satShift < 0) then
    newColor.saturation = lerp(newColor.saturation, 0, -satShift)
  end

  -- SHIFT LIGHTNESS
  if (lightShift > 0) then
    newColor.lightness = lerp(newColor.lightness, 1, lightShift)
  elseif (lightShift < 0) then
    newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
  end

  -- SHIFT SHADING
  local newShade = Color {red = newColor.red, green = newColor.green, blue = newColor.blue}
  local shadeInt = 0
  if (shadeShift >= 0) then
    newShade.hue = 50
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), shadeShift)
  elseif (shadeShift < 0) then
    newShade.hue = 215
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), -shadeShift)
  end
  newColor.red = shadeInt >> 16
  newColor.green = shadeInt >> 8 & 255
  newColor.blue = shadeInt & 255

  return newColor
end

-- custom functions ----------------------------------------------------------------

local function calculateColors(baseColor)

  -- CORE COLOR 
  coreColor = baseColor;

  -- -- SHADING COLORS
  S1 = colorShift(baseColor, 0, 0.3, -0.6, -0.6);
  S2 = colorShift(baseColor, 0, 0.2, -0.2, -0.3);
  S3 = colorShift(baseColor, 0, 0.1, -0.1, -0.1);
  S5 = colorShift(baseColor, 0, 0.1, 0.1, 0.1);
  S6 = colorShift(baseColor, 0, 0.2, 0.2, 0.2);
  S7 = colorShift(baseColor, 0, 0.3, 0.5, 0.4);
  
  -- LIGHTNESS COLORS
  L1 = colorShift(baseColor, 0, 0, -0.4, 0);
  L2 = colorShift(baseColor, 0, 0, -0.2, 0);
  L3 = colorShift(baseColor, 0, 0, -0.1, 0);
  L5 = colorShift(baseColor, 0, 0, 0.1, 0);
  L6 = colorShift(baseColor, 0, 0, 0.2, 0);
  L7 = colorShift(baseColor, 0, 0, 0.4, 0);
  
  -- SATURATION COLORS
  C1 = colorShift(baseColor, 0, -0.5, 0, 0);
  C2 = colorShift(baseColor, 0, -0.2, 0, 0);
  C3 = colorShift(baseColor, 0, -0.1, 0, 0);
  C5 = colorShift(baseColor, 0, 0.1, 0, 0);
  C6 = colorShift(baseColor, 0, 0.2, 0, 0);
  C7 = colorShift(baseColor, 0, 0.5, 0, 0);
  
  -- HUE COLORS
  H1 = colorShift(baseColor, -0.15, 0, 0, 0);
  H2 = colorShift(baseColor, -0.1, 0, 0, 0);
  H3 = colorShift(baseColor, -0.05, 0, 0, 0);
  H5 = colorShift(baseColor, 0.05, 0, 0, 0);
  H6 = colorShift(baseColor, 0.1, 0, 0, 0);
  H7 = colorShift(baseColor, 0.15, 0, 0, 0);

end

local function updateDialogData()

  dlg:modify{ id="base",
    colors = {FGcache, BGcache};
  }
  dlg:modify{ id="sha",
    colors = {S1, S2, S3, coreColor, S5, S6, S7};
  }
  dlg:modify{ id="lit",
    colors = {L1, L2, L3, coreColor, L5, L6, L7};
  }
  dlg:modify{ id="sat",
  colors = {C1, C2, C3, coreColor, C5, C6, C7};
  }
  dlg:modify{ id="hue",
  colors = {H1, H2, H3, coreColor, H5, H6, H7};
  }

end

local function oneShadesClick(ev)
  eyeDropper = false;
      
  if(ev.button == MouseButton.LEFT) then
    app.fgColor = ev.color

  elseif(ev.button == MouseButton.RIGHT) then

    app.bgColor = ev.color

  elseif(ev.button == MouseButton.MIDDLE) then
    app.fgColor = ev.color
    calculateColors(app.fgColor)
    updateDialogData()
  end

end

local function createDialog()

  FGcache = app.fgColor;
  BGcache = app.bgColor

  dlg = Dialog {
  title = "Color Shading",
  onclose = function()
   --onDialog close
   app.events:off(fgListenerCode)
   app.events:off(bgListenerCode)
  
  end
  }

  -- DIALOGUE
  dlg:
  shades {
     -- SAVED COLOR BASES
    id = "base",
    label = "Base",
    colors = {FGcache, BGcache},
    onclick = function(ev)
      calculateColors(ev.color)
      updateDialogData()
    end
  }:button {
    -- GET BUTTON
    id = "get",
    text = "Get",
    onclick = function()
      FGcache = app.fgColor;
      BGcache = app.bgColor;
      calculateColors(app.fgColor)
      updateDialogData()
    end
  }:shades {
     -- SHADING
    id = "sha",
    label = "Shade",
    colors = {S1, S2, S3, coreColor, S5, S6, S7},
    onclick = function(ev)

      oneShadesClick(ev)

    end
  }:shades {
     -- LIGHTNESS
    id = "lit",
    label = "Light",
    colors = {L1, L2, L3, coreColor, L5, L6, L7},
    onclick = function(ev)
      oneShadesClick(ev)

    end
  }:shades {
     -- SATURATION
    id = "sat",
    label = "Sat",
    colors = {C1, C2, C3, coreColor, C5, C6, C7},
    onclick = function(ev)
      oneShadesClick(ev)

    end
  }:shades {
     -- HUE
    id = "hue",
    label = "Hue",
    colors = {H1, H2, H3, coreColor, H5, H6, H7},
    onclick = function(ev)
      oneShadesClick(ev)

    end
  }:check{ 
    id = "check",
    label = "Mode",
    text = "Auto Pick",
    selected = autoPick,
    onclick = function()
      
      autoPick = not autoPick;
    end
  }

  dlg:show {wait = false}
end


local function onFgChange()
  if(eyeDropper == true and autoPick == true) then
    FGcache = app.fgColor;
    BGcache = app.bgColor;
    calculateColors(app.fgColor)
    updateDialogData()
  elseif(eyeDropper == false) then
    --print("inside shades")
  end
  eyeDropper = true;
end

-- run the script ------------------------------------------------------------------
do
  calculateColors(app.fgColor)
  createDialog();
  fgListenerCode = app.events:on('fgcolorchange', onFgChange);
  bgListenerCode = app.events:on('bgcolorchange', onFgChange);
end