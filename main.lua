--[[
╦  ┌─┐┌─┐┌─┐┬    ╔╗ ┬┌┬┐┌─┐ 
║  ├┤ │ ┬├─┤│    ╠╩╗│ │ └─┐ 0
╩═╝└─┘└─┘┴ ┴┴─┘  ╚═╝┴ ┴ └─┘ 0

None of this code is optimized or guaranteed to work, but you're welcome
to use any of it in your own programs. The only thing I ask is if you use
or modify the "Right Crank Menu" context-sensitive scrolling icon selector,
that you credit u/ConfidentFloor6601 for the original implementation in 
your source code.

You're on your own for icons and stuff -- pixel art is actual effort at 
these scales, so I'm going to hang onto any copyrights for artwork I've
shared on Reddit and elsewhere. (The icons aren't that great anyway.)

╔═╗┌─┐┌┬┐┌┬┐┬┌┐┌┌─┐  ╔═╗┌┬┐┌─┐┬─┐┌┬┐┌─┐┌┬┐
║ ╦├┤  │  │ │││││ ┬  ╚═╗ │ ├─┤├┬┘ │ ├┤  ││ 0
╚═╝└─┘ ┴  ┴ ┴┘└┘└─┘  ╚═╝ ┴ ┴ ┴┴└─ ┴ └─┘─┴┘ 0

This code is written in Lua. If you don't know Lua, fighting with my
terrible code may be a good learning experience, but even if not, you
will need to install a compiler or an IDE for compiling all of this
into something resembling a functional program. I'm using ZeroBrane 
Studio on Windows 10; it seems to work fine, but I can't assume any
responsibility if it's actually riddled with malware or otherwise
nukes your system. With that glowing endorsement in place, you can
find it here: https://studio.zerobrane.com

This code requires LÖVE; there are instructions for downloading and
installing LÖVE at love2d.org. I'll let you figure that part out for
your own system, if you don't already have it running.

Icons that fit the current RCM are 36x36, with a two-pixel border for each
drawn by the RCM. The RCM occupies 40x240 pixels. The Left Context Menu (LCM)
occupies 100x240, leaving 240x240 in the middle for actual game content.
All of that can be changed in the code, so don't feel stuck with it.

For my pixel art, I've been using the offline version of Piskel on my
PC (https://www.piskelapp.com), and Pixel Studio on my android phone
(https://play.google.com/store/apps/details?id=com.PixelStudio)
Once again, I take absolutely no responsibility for either app, but
from my experience, Piskel is more intuitive, so I've done all of my
icons there, but Pixel Studio looks more powerful, is cross-platform,
and has more tools -- It just annoys me because I can never remember
where the save button is hidden.

I'm still teaching myself Lua, coming from C/C++ and Python, so a lot of 
this code feels really ugly to me, and it probably is. If you find better
ways to implement any of these functions, I'd love to hear about it, but 
don't waste your time dunking on me because I already know it's bad rn.

If you have any questions, feel free to DM me on Reddit. When I have some-
thing that more closely resembles a game, I'll probably start a Twitter or
something for it, but I'll announce that in r/playdate anyway.

Cheers and Happy Coding,
the Door Demon
]]


-- Banners from: https://manytools.org/hacker-tools/ascii-banner/
-- Font: Calvin S
-- Reason: I have a hard time finding functions in Lua, lol


--[[ 
╔═╗╦  ╔═╗╔╗ ╔═╗╦    ╦  ╦╔═╗╦═╗╦╔═╗╔╗ ╦  ╔═╗╔═╗
║ ╦║  ║ ║╠╩╗╠═╣║    ╚╗╔╝╠═╣╠╦╝║╠═╣╠╩╗║  ║╣ ╚═╗
╚═╝╩═╝╚═╝╚═╝╩ ╩╩═╝   ╚╝ ╩ ╩╩╚═╩╩ ╩╚═╝╩═╝╚═╝╚═╝
]]

-- Titles for the icons selected with the Right Crank Menu (RCM)
menu_titles = 
{{"Look",       "look.png"},
  {"Talk",      "talk.png"},
  {"Fight",     "fight.png"},
  {"Magic",     "magic.png"},
  {"Gear",      "equipment.png"},
  {"Inventory", "items.png"},
  {"Quest Log", "quests.png"},
  {"Game Files","files.png"},
  {"Settings",  "settings.png"}}
-- The number of icons in the menu may get larger later, I dunno
menu_length = table.maxn(menu_titles)

menu_files = {"New","Load","Save","Quit"}
LCM_files_selected = "New"

-- Crank icon dimensions (including borders)
Ico_W, Ico_H = 40,40
-- Playdate screen dimensions
Scr_W, Scr_H = 400,240

-- Initial value for icon_name
icon_name = "Look"
-- Using the default font until I find something better
love.graphics.setNewFont(18)

-- My usb knob does 30 clicks per rotation, so 12' per click
-- No way to track absolute angle between runs so assume 0'
knob_angle = 0
-- Set to 0 means no recent clicks
prev_click_time = 0
next_click_time = 0

-- The most recent crank velocity
crank_velocity = 0
-- The most recent direction the crank was turned. +=cw, -=ccw
crank_direction = 0
-- Set the initial icon to number 0 (Look)
crank_offset = 0
-- Set the initial game file selection to 0 (New)
files_offset = 0
-- max value should be height of icon x number of icons
crank_maxval = 40 * menu_length
-- Screen width of playdate is 400px

-- Which menu is the crank currently attached to?
active_menu = "RCM"


--[[
╔═╗╦ ╦╔╗╔╔═╗╔╦╗╦╔═╗╔╗╔╔═╗
╠╣ ║ ║║║║║   ║ ║║ ║║║║╚═╗
╚  ╚═╝╝╚╝╚═╝ ╩ ╩╚═╝╝╚╝╚═╝
]]



--[[
┬  ┌─┐┬  ┬┌─┐ ┬  ┌─┐┌─┐┌┬┐
│  │ │└┐┌┘├┤  │  │ │├─┤ ││
┴─┘└─┘ └┘ └─┘o┴─┘└─┘┴ ┴─┴┘

Should load any external assets in this function instead of in global
space. I believe love.load() is run before love.draw(), but if any of
the functions run before love.draw there are no guarantees.
]]

function love.load()
  print(_VERSION)
  
  for index,value in ipairs(menu_titles) do
      menu_titles[index][3] = love.graphics.newImage(menu_titles[index][2])
  end
  
  gear_bg = love.graphics.newImage("figure.png")
  
  -- Final version will be 1-bit color, but red == unfinished
  love.graphics.setBackgroundColor(0,0,0,255)
  
  -- Playdate screen should be 400x240. 
  -- Might add magnification factor for pixel doubling on PC
  love.window.setMode(Scr_W,Scr_H,{resizable=false})
  love.window.setTitle("Your Game Title Here")
end


--[[
┬  ┌─┐┬  ┬┌─┐ ┌┬┐┬─┐┌─┐┬ ┬
│  │ │└┐┌┘├┤   ││├┬┘├─┤│││
┴─┘└─┘ └┘ └─┘o─┴┘┴└─┴ ┴└┴┘
]]
function love.draw()
  -- Crank-selected Menu Main Box Outline
  love.graphics.rectangle("line",2,2,116,236)
  
  -- Right Crank Menu Box Outlines and Icons
  for index,value in ipairs(menu_titles) do
    draw_icon(menu_titles[index][3],index-1)
  end
    
  -- Hacky "active icon" selector box here
  if active_menu == "RCM" then
    love.graphics.rectangle("line",360,100,40,40)
    love.graphics.rectangle("line",361,101,39,39)
  end

  --[[ 
      The selector box for the LCM will disappear when the RCM is active.
    ]]
  if active_menu == "LCM" then
    love.graphics.rectangle("line",3,3,112,24)
  end
  
  --[[
    Save File Management Menu
  ]]
  if icon_name == "Game Files" then
      draw_LCM_Files()
    elseif icon_name == "Gear" then
      draw_LCM_Gear()
  end
    
  -- Any text goes down here
  print_selected_icon()
  
  --[[
    Debuggery here: uncomment to see on-screen crank stats
  ]]
  love.graphics.print({{255,0,0,255},"Angle: ",{255,0,0,255},knob_angle},125,5)
  love.graphics.print({{255,0,0,255},"°/sec: ",{255,0,0,255},crank_velocity},125,25)
end


--[[
┌─┐┬─┐┬┌┐┌┌┬┐   ┌─┐┌─┐┬  ┌─┐┌─┐┌┬┐┌─┐┌┬┐    ┬┌─┐┌─┐┌┐┌
├─┘├┬┘││││ │    └─┐├┤ │  ├┤ │   │ ├┤  ││    ││  │ ││││
┴  ┴└─┴┘└┘ ┴────└─┘└─┘┴─┘└─┘└─┘ ┴ └─┘─┴┘────┴└─┘└─┘┘└┘

    print_selected_icon grabs the name of each icon from the RCM, and
    prints it to the box located at the top of the LCM. This doesn't
    activate that selection in the LCM, just displays it. To activate
    the LCM (or give it focus) the user will have to press left.
]]
function print_selected_icon()
  icon_selection = ((crank_maxval - crank_offset)/40)%menu_length
  --love.graphics.print( ((crank_maxval - crank_offset)/40)%6 , 40,60)
  if icon_selection%1 == 0 then
    icon_name = menu_titles[icon_selection+1][1]
    
  end
  love.graphics.printf(icon_name,0,3,120,"center")

end


--[[
┌┬┐┬─┐┌─┐┬ ┬    ┬┌─┐┌─┐┌┐┌
 ││├┬┘├─┤│││    ││  │ ││││
─┴┘┴└─┴ ┴└┴┘────┴└─┘└─┘┘└┘
    draw_icon does just that: draws a single icon to the right crank menu.
    There's no reason this shouldn't just iterate through the table of 
    icons, though; I'll change that in the next revision.
]]
function draw_icon(icon, order)
  --[[
  crank_offset ranges between 0 and 239 (really 232), but we add 2
  to that to give the icons a buffer from the top, and add another
  100 to shift our first icon into the centered selection box.
  
    ONLY UPDATES WHEN RCM IS IN FOCUS!
  ]]
  local height = ((order*40)+crank_offset+102)%crank_maxval
  local width = 362+((100-height)^2)/1000
  
  if (height >= crank_maxval-40) then
    -- width2 is a temporary variable to keep the icons on the curve
    -- the the top and bottom of the screen
    width2 = 362+((100-(height-crank_maxval))^2)/1000
    love.graphics.rectangle("line",width2,height-crank_maxval,36,36)
    love.graphics.draw(icon,width2+1,height-crank_maxval)
  end

  love.graphics.rectangle("line",width,height%crank_maxval,36,36)
  love.graphics.draw(icon,width+1,height%crank_maxval)
  
end


--[[
┌┬┐┬─┐┌─┐┬ ┬    ╦  ╔═╗╔╦╗    ╔═╗┌─┐┌─┐┬─┐
 ││├┬┘├─┤│││    ║  ║  ║║║    ║ ╦├┤ ├─┤├┬┘
─┴┘┴└─┴ ┴└┴┘────╩═╝╚═╝╩ ╩────╚═╝└─┘┴ ┴┴└─

Might rearrange this a bit to provide space for items mapped to the 
A and B buttons during combat. Probably shift everything down, and 
place squares on either side of the head. I dunno.
]]
function draw_LCM_Gear()
  
  --[[
  Figure Background
  ]]
  love.graphics.draw(gear_bg,6,30)
  
  --[[
  Helmet
  ]]
  love.graphics.setColor(0,0,0,255)
  love.graphics.rectangle("line",41,30,36,36)
  love.graphics.setColor(255,255,255,255)
  love.graphics.rectangle("line",42,31,34,34)
  
  --[[
  Armor
  ]]
  love.graphics.setColor(0,0,0,255)
  love.graphics.rectangle("line",20,71,75,64)
  love.graphics.setColor(255,255,255,255)
  love.graphics.rectangle("line",21,72,73,62)

  --[[
  Sword
  ]]
  love.graphics.setColor(0,0,0,255)
  love.graphics.rectangle("line",20,140,24,84)
  love.graphics.setColor(255,255,255,255)
  love.graphics.rectangle("line",21,141,22,82)
  
  --[[
  Shield
  ]]
  love.graphics.setColor(0,0,0,255)
  love.graphics.rectangle("line",60,140,42,62)
  love.graphics.setColor(255,255,255,255)
  love.graphics.rectangle("line",61,141,40,60)

end


--[[
┌┬┐┬─┐┌─┐┬ ┬    ╦  ╔═╗╔╦╗    ╔═╗┬┬  ┌─┐┌─┐
 ││├┬┘├─┤│││    ║  ║  ║║║    ╠╣ ││  ├┤ └─┐
─┴┘┴└─┴ ┴└┴┘────╩═╝╚═╝╩ ╩────╚  ┴┴─┘└─┘└─┘

This needs a lot of work still, but you get the idea.
]]
function draw_LCM_Files()
--[[
  NEW GAME
]]
  love.graphics.printf("New",0,60,120,"center")
  if active_menu == "LCM" and files_offset == 0 then
      love.graphics.rectangle("line",20,60,80,25)
  end
  
--[[
  LOAD GAME
]]
  love.graphics.printf("Load",0,100,120,"center")
  if active_menu == "LCM" and files_offset == 1 then
      love.graphics.rectangle("line",20,100,80,25)
  end
  
--[[
  SAVE GAME
]]
  love.graphics.printf("Save",0,140,120,"center")
    if active_menu == "LCM" and files_offset == 2 then
      love.graphics.rectangle("line",20,140,80,25)
  end
--[[
  QUIT GAME
]]
  love.graphics.printf("Quit",0,180,120,"center")
    if active_menu == "LCM" and files_offset == 3 then
      love.graphics.rectangle("line",20,180,80,25)
  end
end


--[[
┬  ┌─┐┬  ┬┌─┐ ┬┌─┌─┐┬ ┬┌─┐┬─┐┌─┐┌─┐┌─┐┌─┐┌┬┐
│  │ │└┐┌┘├┤  ├┴┐├┤ └┬┘├─┘├┬┘├┤ └─┐└─┐├┤  ││
┴─┘└─┘ └┘ └─┘o┴ ┴└─┘ ┴ ┴  ┴└─└─┘└─┘└─┘└─┘─┴┘
  Buttons will function differently depending on which menu or screen is
  currently in focus, so our keyparser needs to be aware of which state 
  it is in.
  
  ABSOLUTE ANGLE (knob_angle) must be updated with every click, however.
  Each click is 12' +/- previous value
]]
function love.keypressed(key)
  if active_menu == "RCM" then
    
    if key == "kp+" or key == "up" then
      knob_angle = (knob_angle - 12)%360
      crank_offset = (crank_offset + 8)%crank_maxval
      crank_direction = -1
    elseif key == "kp-" or key == "down" then
      knob_angle = (knob_angle + 12)%360
      crank_offset = (crank_offset - 8)%crank_maxval
      crank_direction = 1
    end
    if key == "a" or key == "left" then
      active_menu = "LCM"
    end
    
  elseif active_menu == "LCM" then
    
    if key =="kp+" or key == "up" then
      knob_angle = (knob_angle - 12)%360
      files_offset = (files_offset - 1)%4
      crank_direction = -1
    elseif key == "kp-" or key == "down" then
      knob_angle = (knob_angle +12)%360
      files_offset = (files_offset + 1)%4
      crank_direction = 1
    elseif key == "d" or key == "right" then
        active_menu = "RCM"
    end
    
  end
  crank_velocity = get_crank_velocity()
end


--[[
┌─┐┌─┐┌┬┐   ┌─┐┬─┐┌─┐┌┐┌┬┌─   ┬  ┬┌─┐┬  ┌─┐┌─┐┬┌┬┐┬ ┬
│ ┬├┤  │    │  ├┬┘├─┤│││├┴┐   └┐┌┘├┤ │  │ ││  │ │ └┬┘
└─┘└─┘ ┴────└─┘┴└─┴ ┴┘└┘┴ ┴────└┘ └─┘┴─┘└─┘└─┘┴ ┴  ┴ 
]]
function get_crank_velocity()
  prev_click_time = next_click_time
  next_click_time = love.timer.getTime()
  if prev_click_time == 0 then
    return 18 -- Magic Number, don't care.
  else
    return (12 * crank_direction) / (next_click_time - prev_click_time)
  end
end
