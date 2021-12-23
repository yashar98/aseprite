# aseprite
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
