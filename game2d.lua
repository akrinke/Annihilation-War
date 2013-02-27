--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~---~~--~~--~~--~~--~~--~~--~~--~~
--AUTHOR: EVERTON COSTA
--LICENSE: MIT
--DATE: 09/06/2010 18:12
--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~---~~--~~--~~--~~--~~--~~--~~--~~
--PREPARATIONS
package.cpath = package.cpath..';./game2d/?.dll;'
require('lfs')
--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~---~~--~~--~~--~~--~~--~~--~~--~~
--FUNCTIONS
function split(v,s)
	local r={}
	local t=''
	for i=1,string.len(v) do
		if string.sub(v,i,i)==s then
			table.insert(r, t)
			t=''
		else
			t=t..string.sub(v,i,i)
		end
	end
	table.insert(r, t)
	return r
end
function replace_char(v,f,r)
	local e = ""
	local t = ""
	for i=1,#v do
		if string.lower(string.sub(v,i,i))==string.lower(f) then
			t = r
		else
			t = string.sub(v,i,i)
		end
		e = e..t
	end
	return e
end
function getFilename(filename)
	filename = replace_char( filename, '\\', '/' )
	filename = split(filename,'/')[#split(filename,'/')]
	return tostring(filename)
end
function table_duplicate(t)
	local r = {}
	for i=1, #t do
		if type(t[i])=='table' then
			r[i]=table_duplicate(t[i])
		else
			r[i]=t[i]
		end
	end
	return r
end
function random_integer(a, b)
	if a then
		if type(a)=='number' and type(b)=='number' then
			if b < a then return 0
			elseif b==a then return b end
			for i=1, random_integer()+1 do
				math.random()
			end
			return math.random(a, b)
		else ERROR()
		end
	end
	return tonumber(split(tostring(math.random()*(scrupp.getTicks()/os.time(sec))),'.')[1])
end
--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~---~~--~~--~~--~~--~~--~~--~~--~~
--CLASS
function class(base,ctor)
  local c = {}
  if not ctor and type(base) == 'function' then
      ctor = base
      base = nil
  elseif type(base) == 'table' then
      for i,v in pairs(base) do
          c[i] = v
      end
      c._base = base
  end
  c.__index = c
  local mt = {}
  mt.__call = function(class_tbl,...)
    local obj = {}
    setmetatable(obj,c)
	if ctor then
       ctor(obj,...)
    else
       if base and base.init then
         base.init(obj,...)
       end
    end
    return obj
  end
  c.init = ctor
  c.is_a = function(self,klass)
      local m = getmetatable(self)
      while m do
         if m == klass then return true end
         m = m._base
      end
      return false
    end
  setmetatable(c,mt)
  return c
end
--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~---~~--~~--~~--~~--~~--~~--~~--~~
--game2d
local function ERROR(message)
	local msg = message or 'Inconvenience Found!'
	error('GAME2D for Scrupp \n\n'..msg, 2)
	scrupp.exit()
end
local function getMouseDevice()
	local mouse = { 'left', 'right', 'middle' }
	local r = {}
	for i=1, #mouse do
		if scrupp.mouseButtonIsDown(mouse[i]) then
			r[#r+1] = mouse[i]
		end
	end
	return r
end
local function getKeyboardDevice()
	local keyboard =	{	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
						'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12',
						'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
						'LEFT', 'RIGHT', 'UP', 'DOWN',
						'KP1', 'KP2', 'KP3', 'KP4', 'KP5', 'KP6', 'KP7', 'KP8', 'KP9', 'KP0', 'KP_ENTER', 'KP_DIVIDE', 'KP_MULTIPLY', 'KP_MINUS', 'KP_PLUS',
						'ESCAPE', 'TAB', 'CAPSLOCK', 'LSHIFT', 'LALT', 'SPACE', 'MENU', 'LCTRL', 'RCTRL', 'RSHIFT', 'PAGEUP',
						'RETURN', 'BACKSPACE', 'PRINT', 'SCROLLOCK', 'PAUSE', 'HOME', 'END', 'INSERT', 'DELETE', 'PAGEDOWN'
					}
	local r = {}
	for i=1, #keyboard do
		if scrupp.keyIsDown(keyboard[i]) then
			r[#r+1] = keyboard[i]
		end
	end
	return r
end
local image_types = 'bmp|pnm|ppm|pgm|pbm|xpm|lbm|pcx|gif|jpeg|png|tiff|jpg|tif'
local sound_types = 'wav|aiff|riff|ogg|voc|aif|rif'
local font_types  = 'ttf|fon'
--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~---~~--~~--~~--~~--~~--~~--~~--~~
--CONSTANTS
require('game2d.constants')
--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~--~~---~~--~~--~~--~~--~~--~~--~~--~~
--game2d CLASS
game2d	=	class()
function game2d:init(title, res, fullscreen)
	fullscreen = fullscreen or false
	if res[1] < 200 or res[2]<200 then ERROR('Resolution Invalid') end
	scrupp.init(title..' - GAME2D (paused)', res[1], res[2], 32, fullscreen, false)
	scrupp.setDelta(_SECOND_)
	scrupp.showCursor(false)
	require ('game2d.interface_game2d')
	local GAME = nil
	local game =	class(
		function(self)
			self.W = res[1]
			self.H = res[2]
			self.TITLE = title..' - GAME2D'
			self.FULLSCREEN = fullscreen
			self.defaultSoundVolume = _LOUD_
			self.defaultFontSize	= _FONTSIZE_
			self.MOUSEX = 0
			self.MOUSEY = 0
			self.MOUSE = nil
			self.MOUSEINDEX = nil
			self.CURSOR = scrupp.addImage('game2d/cursor.png')
			self.CURSORSHOW = true
			self.events = {}
			self.FILES = {}
			self.GUICLASS = false
			self.MOUSECLASS = false
			self.RESOURCESCLASS = false
			self.RUNNING = false
			self.LALT = false
			self.DELTA = _SECOND_
			self.GUIDESKTOP = nil
			self.GUICONTROLS = {}
			self.SPRITES = {}
			self.PARKS = {}
			self.PARK = nil
			self.SOUNDS = {}
			self.TIMERS = {}
			self.SCALEX = 1
			self.SCALEY = 1
			GAME = self
		end
	)
	function game:isSprite(spr)
		spr = spr or ERROR()
		if type(spr)~='table' then return false end
		if spr.TYPE==_SPRITE_ or spr.TYPE==_INSTANCE_ then
			return true
		else
			return false
		end
	end
	function game:isPark(prk)
		prk = prk or ERROR()
		if type(prk)~='table' then return false end
		if prk.TYPE==_PARK_ then
			return true
		else
			return false
		end
	end
	function game:setPark(park)
		if not park then
			self.PARK = nil
			return
		end
		local ok = false
		for i=1, #self.PARKS do
			if self.PARKS[i]==park then
				ok = true
			end
		end
		if ok then
			self.PARK = park
		else
			ERROR('Park Not Found')
		end
	end
	function game:EVENT(evt, ...)
		if type(evt)~='string' then ERROR() end
		if type(GAME.events[evt]) == 'function' then
			return GAME.events[evt](...)
		end
	end
	function game:RESOURCE(name, n)
		if type(name)~='string' or #self.FILES==0 then return end
		name = getFilename(name)
		local function getHandle(filename, t)
			for i=1, #self.FILES do
				if string.lower(split(string.lower(self.FILES[i]),'/')[#split(self.FILES[i],'/')])==string.lower(filename) then
					t = t or _IMAGE_
					if t==_IMAGE_ then
						if tostring(n)==_NAME_ then
							return self.FILES[i], _IMAGE_
						end
						return scrupp.addImage(self.FILES[i])
					elseif t==_SOUND_ then
						if tostring(n)==_NAME_ then
							return self.FILES[i], _SOUND_
						end
						return scrupp.addSound(self.FILES[i])
					elseif t==_FONT_ then
						if tostring(n)==_NAME_ then
							return self.FILES[i], _FONT_
						end
						return scrupp.addFont(self.FILES[i], n or _FONTSIZE_)
					end
				end
			end
		end
		local ext = split(name,'.') ext = string.lower(ext[#ext])
		for i=1, #image_types do
			if ext==split(image_types,'|')[i] then
				return getHandle(name)
			end
		end
		for i=1, #sound_types do
			if ext==split(sound_types,'|')[i] then
				return getHandle(name, _SOUND_)
			end
		end
		for i=1, #font_types do
			if ext==split(font_types,'|')[i] then
				return getHandle(name, _FONT_)
			end
		end
	end
	function game:resume()
		self.RUNNING = true
		if not self.FULLSCREEN then
			scrupp.init(self.TITLE, self.W, self.H, 32, self.FULLSCREEN, false)
		end
		GAME:EVENT('onGameResume')
		scrupp.resetView()
		scrupp.scaleView(self.SCALEX, self.SCALEY)
	end
	function game:pause()
		self.RUNNING = false
		if not self.FULLSCREEN then
			scrupp.init(self.TITLE..' (paused)', self.W, self.H, 32, self.FULLSCREEN, false)
		end
		GAME:EVENT('onGamePause')
		scrupp.resetView()
		scrupp.scaleView(self.SCALEX, self.SCALEY)
	end
	function game:paused()
		return not self.RUNNING
	end
	function game:exit()
		local r = game:EVENT('onGameExit')
		if r == _ABORT_ then return end
		scrupp.exit()
	end
	function game:mouse()
		if self.MOUSECLASS then
			ERROR('Mouse object already exists in game class')
		end
		local mouse = class()
		function mouse:x()
			return GAME.MOUSEX*GAME.SCALEX
		end
		function mouse:y()
			return GAME.MOUSEY*GAME.SCALEY
		end
		function mouse:spriteCursor(spr)
			if type(spr)=='nil' then
				return GAME.MOUSE
			elseif spr.TYPE==_SPRITE_ then
				for i=1, #GAME.SPRITES do
					if GAME.SPRITES[i]==spr then
						GAME.MOUSE = spr
						GAME.MOUSEINDEX=i
						return
					end
				end
				ERROR('Sprite Not Found')
			end
		end
		function mouse:showing(show)
			if type(show)=='nil' then
				return GAME.CURSORSHOW
			elseif type(show)=='boolean' then
				GAME.CURSORSHOW = show
			end
		end
		self.MOUSECLASS = true
		return mouse()
	end
	function game:gui(fnt, fntSize)
		if self.GUICLASS then
			ERROR('Gui object already exists in game class')
		end
		local GUI = nil
		local gui = class(function(self)
			self.FONT = GAME:RESOURCE(fnt, fntSize) or scrupp.addFont('game2d/DejaVuSansMono.ttf', _FONTSIZE_)
			self.CONTROLS = {}
			self.visible = _YES_
			self.alpha = _OPAQUE_
			self.image = _EMPTY_
			self.bgColor = _BLACK_
			self.bgVisible = _YES_
			self.defaultAlpha = _OPAQUE_
			self.defaultVisible = _YES_
			self.defaultEnabled = _YES_
			self.defaultFgColor = _RED_
			self.defaultBgColor = { 180, 180, 180, 180 }
			self.defaultBorderColor = { 255, 255, 255, 255}
			GAME.GUIDESKTOP = interface.addDesktop()
			GAME.GUIDESKTOP:setAlpha(self.alpha)
			GAME.GUIDESKTOP:setImage(self.image)
			GAME.GUIDESKTOP:setVisible(self.visible)
			GAME.GUIDESKTOP.showBack = self.showBack
			GUI = self
			GAME.GUICONTROLS[#GAME.GUICONTROLS+1] = GUI
		end)
		function gui:setDefaultFont(fnt, fntSize)
			if type(fnt)=='number' then
				self.FONT = scrupp.addFont('game2d/DejaVuSansMono.ttf', fnt)
				return
			end
			fntSize = fntSize or 12
			self.FONT = GAME:RESOURCE(fnt, fntSize)
		end
		function gui:update()
			GAME.GUIDESKTOP.bgVisible = self.bgVisible
			GAME.GUIDESKTOP:setVisible(self.visible)
			GAME.GUIDESKTOP:setAlpha(self.alpha)
			GAME.GUIDESKTOP:setImage(GAME:RESOURCE(self.image))
			GAME.GUIDESKTOP:setBgColor(self.bgColor)
		end
		function gui:includeButton(images)
			local btn = class(function(self)
				self.CONTROLINDEX = #GAME.GUICONTROLS+1
				local im = nil
				if images then
					im = {}
					if images[2]==nil then images[2] = images[1] end
					if images[3]==nil then images[3] = images[1] end
					if images[4]==nil then images[4] = images[1] end
					for i=1, 4 do
						im[i] = GAME:RESOURCE(images[i], _NAME_) or ERROR('Image Not Found ['..images[i]..']')
					end
				end
				self.CONTROL = interface.addButton(function() end, im)
				images = nil
				im = nil
				self.CONTROL = GAME.GUIDESKTOP:addControl(self.CONTROL)
				self.CONTROL.connected = true
				self.CONTROL.connector = GAME.GUIDESKTOP
				self.FONT = GUI.FONT
				self.CONTROL:setVisible(GUI.defaultVisible)
				self.CONTROL:setAlpha(GUI.defaultAlpha)
				self.CONTROL.font = self.FONT
				self.TIP = nil
				self.TIPCONNECTOR = {}
				self.CONTROL.sX = GAME.SCALEX
				self.CONTROL.sY = GAME.SCALEY
				self.w = (self.CONTROL:getDimension().w/GAME.SCALEX)
				self.h = (self.CONTROL:getDimension().h/GAME.SCALEY)
				self.x = self.CONTROL:getPosition().x
				self.y = self.CONTROL:getPosition().y
				self.alpha = self.CONTROL:getAlpha()
				self.text = self.CONTROL:getText()
				self.visible = GUI.defaultVisible
				self.fgColor = GUI.defaultFgColor
				self.enabled = GUI.defaultEnabled
				self.keys = {}
				self.onClick = function() end
				self.onMouseOver = function() end
				self.onMouseLeave = function() end
			end)
			function btn:exclude()
				GAME.GUIDESKTOP:removeControl(self.CONTROL)
				GAME.GUICONTROLS[self.CONTROLINDEX] = nil
				self.CONTROL = nil
			end
			function btn:setTip(tip, tipText, tipDelay)
				if tip then
					self.TIP = { tip, tipText or 'Tip', tipDelay or 250 }
					self.TIPCONNECTOR = tip
					self.CONTROL:Tip(self.TIP[1].CONTROL, self.TIP[2], self.TIP[3])
				else
					self.TIP = nil
					self.CONTROL:Tip()
				end
			end
			function btn:update()
				if self.TIPCONNECTOR then
					if self.TIPCONNECTOR.CONTROL==nil then
						self.CONTROL:removeTip()
						self.TIP = nil
						self.TIPCONNECTOR = nil
					end
				end
				self.CONTROL.sX = GAME.SCALEX
				self.CONTROL.sY = GAME.SCALEY
				self.CONTROL:setDimension({self.w/GAME.SCALEX, self.h/GAME.SCALEY})
				self.CONTROL:setPosition({self.x/GAME.SCALEX, self.y/GAME.SCALEY})
				self.CONTROL:setAlpha(self.alpha)
				self.CONTROL:setVisible(self.visible)
				self.CONTROL:setText(self.text)
				self.CONTROL:setFgColor(self.fgColor)
				self.CONTROL:setKeys(self.keys)
				self.CONTROL:setEnabled(self.enabled)
			end
			local obj = btn()
			GAME.GUICONTROLS[obj.CONTROLINDEX] = obj
			obj.CONTROL.callback = function() GAME.GUICONTROLS[obj.CONTROLINDEX].onClick() GAME:EVENT('onButtonClick', obj) end
			obj.CONTROL.callbackMouseOver = function() GAME.GUICONTROLS[obj.CONTROLINDEX].onMouseOver() GAME:EVENT('onButtonMouseOver',  obj) end
			obj.CONTROL.callbackMouseLeave = function() GAME.GUICONTROLS[obj.CONTROLINDEX].onMouseLeave() GAME:EVENT('onButtonMouseLeave',  obj) end
			return obj
		end
		function gui:includeField(images)
			local fld = class(function(self)
				self.CONTROLINDEX = #GAME.GUICONTROLS+1
				if images then
					if images[2]==nil then images[2] = images[1] end
					if images[3]==nil then images[3] = images[1] end
					for i=1, 3 do
						images[i]= GAME:RESOURCE(images[i])
					end
				end
				self.CONTROL = interface.addField('Field', nil, images)
				self.CONTROL = GAME.GUIDESKTOP:addControl(self.CONTROL)
				self.CONTROL.connected = true
				self.CONTROL.connector = GAME.GUIDESKTOP
				self.FONT = GUI.FONT
				self.CONTROL:setVisible(GUI.defaultVisible)
				self.CONTROL:setAlpha(GUI.defaultAlpha)
				self.CONTROL.font = self.FONT
				self.TIP = nil
				self.TIPCONNECTOR = {}
				self.CONTROL.sX = GAME.SCALEX
				self.CONTROL.sY = GAME.SCALEY
				self.w = (self.CONTROL:getDimension().w/GAME.SCALEX)
				self.h = (self.CONTROL:getDimension().h/GAME.SCALEY)
				self.x = self.CONTROL:getPosition().x
				self.y = self.CONTROL:getPosition().y
				self.alpha = self.CONTROL:getAlpha()
				self.visible = GUI.defaultVisible
				self.fgColor = GUI.defaultFgColor
				self.bgColor = GUI.defaultBgColor
				self.borderColor = GUI.defaultBorderColor
				self.TEXT = self.CONTROL:getText()
				self.length = _INFINITY_
				self.mask = _ASCII_
				self.INTERVAL = nil
				self.enabled = GUI.defaultEnabled
				if self.mask==_INTEGER_ or self.mask==_DECIMAL_ then
					self:setText('0')
				end
				self.keyboard = _PS2_
				self.onConfirm = function() end
				self.onChange = function() end
				self.onFocus = function() end
			end)
			function fld:setText(txt)
				txt = txt or ERROR()
				self.CONTROL:setText(tostring(txt))
			end
			function fld:setInterval(nmin, nmax)
				if self.mask == "integer" or self.mask == "decimal" then
					nmin = nmin or ERROR()
					nmax = nmax or ERROR()
					if nmin>nmax then ERROR() end
					self.INTERVAL = { min = nmin, max = nmax }
				else
					ERROR('Mask Invalid')
				end
			end
			function fld:exclude()
				GAME.GUIDESKTOP:removeControl(self.CONTROL)
				GAME.GUICONTROLS[self.CONTROLINDEX] = nil
				self.CONTROL = nil
			end
			function fld:getValue()
				return self.CONTROL:getValue()
			end
			function fld:setTip(tip, tipText, tipDelay)
				if tip then
					self.TIP = { tip, tipText or 'Tip', tipDelay or 250 }
					self.TIPCONNECTOR = tip
					self.CONTROL:Tip(self.TIP[1].CONTROL, self.TIP[2], self.TIP[3])
				else
					self.TIP = nil
					self.CONTROL:Tip()
				end
			end
			function fld:update()
				if self.TIPCONNECTOR then
					if self.TIPCONNECTOR.CONTROL==nil then
						self.CONTROL:removeTip()
						self.TIP = nil
						self.TIPCONNECTOR = nil
					end
				end
				self.CONTROL:setMask(self.mask)
				if (self.mask==_INTEGER_ or self.mask==_DECIMAL_) and type(self:getValue())~='number' then
					self:setText(0)
				end
				self.CONTROL:repair()
				self.CONTROL.sX = GAME.SCALEX
				self.CONTROL.sY = GAME.SCALEY
				self.CONTROL:setDimension({self.w/GAME.SCALEX, self.h/GAME.SCALEY})
				self.CONTROL:setPosition({self.x/GAME.SCALEX, self.y/GAME.SCALEY})
				self.CONTROL:setAlpha(self.alpha)
				self.CONTROL:setVisible(self.visible)
				self.TEXT = self.CONTROL:getText()
				self.CONTROL:setFgColor(self.fgColor)
				self.CONTROL:setBgColor(self.bgColor)
				self.CONTROL:setBorderColor(self.borderColor)
				self.CONTROL:setKeyboard(self.keyboard)
				self.CONTROL:setLength(self.length)
				self.CONTROL:setEnabled(self.enabled)
				self.CONTROL.interval = self.INTERVAL
			end
			local obj = fld()
			GAME.GUICONTROLS[obj.CONTROLINDEX] = obj
			obj.CONTROL.callbackOnKeyEnter = function() GAME.GUICONTROLS[obj.CONTROLINDEX].onConfirm() GAME:EVENT('onFieldConfirm', obj) end
			obj.CONTROL.callbackOnKeyChange = function(c) GAME.GUICONTROLS[obj.CONTROLINDEX].onChange() GAME:EVENT('onFieldChange',  obj, c) end
			obj.CONTROL.callbackOnFocus = function() GAME.GUICONTROLS[obj.CONTROLINDEX].onFocus() GAME:EVENT('onFieldFocus',  obj) end
			return obj
		end
		function gui:includeTip()
			local tip = class(function(self)
				self.CONTROLINDEX = #GAME.GUICONTROLS+1
				self.CONTROL = interface.addTip()
				self.FONT = GUI.FONT
				self.CONTROL.font = self.FONT
				self.fgColor = GUI.defaultFgColor
				self.bgColor = GUI.defaultBgColor
				self.borderColor = GUI.defaultBorderColor
			end)
			function tip:exclude()
				GAME.GUICONTROLS[self.CONTROLINDEX] = nil
				self.CONTROL = nil
			end
			function tip:update()
				self.CONTROL.sX = GAME.SCALEX
				self.CONTROL.sY = GAME.SCALEY
				self.CONTROL:setFgColor(self.fgColor)
				self.CONTROL:setBgColor(self.bgColor)
				self.CONTROL:setBorderColor(self.borderColor)
			end
			local obj = tip()
			GAME.GUICONTROLS[obj.CONTROLINDEX] = obj
			return obj
		end
		function gui:includeLabel()
			local lbl = class(function(self)
				self.CONTROLINDEX = #GAME.GUICONTROLS+1
				self.CONTROL = interface.addLabel()
				self.CONTROL = GAME.GUIDESKTOP:addControl(self.CONTROL)
				self.FONT = GUI.FONT
				self.CONTROL:setVisible(GUI.defaultVisible)
				self.CONTROL.font = self.FONT
				self.w = self.CONTROL:getDimension().w/GAME.SCALEX
				self.h = self.CONTROL:getDimension().h/GAME.SCALEY
				self.x = self.CONTROL:getPosition().x
				self.y = self.CONTROL:getPosition().y
				self.text = self.CONTROL:getText()
				self.visible = GUI.defaultVisible
				self.fgColor = GUI.defaultFgColor
				self.bold = _NO_
			end)
			function lbl:exclude()
				GAME.GUIDESKTOP:removeControl(self.CONTROL)
				GAME.GUICONTROLS[self.CONTROLINDEX] = nil
				self.CONTROL = nil
			end
			function lbl:update()
				self.CONTROL.sX = GAME.SCALEX
				self.CONTROL.sY = GAME.SCALEY
				self.CONTROL:setDimension({self.w/GAME.SCALEX, self.h/GAME.SCALEY})
				self.CONTROL:setPosition({self.x/GAME.SCALEX, self.y/GAME.SCALEY})
				self.CONTROL:setVisible(self.visible)
				self.CONTROL:setText(self.text)
				self.CONTROL:setFgColor(self.fgColor)
				self.CONTROL:setBoldState(self.bold)
			end
			local obj = lbl()
			GAME.GUICONTROLS[obj.CONTROLINDEX] = obj
			return obj
		end
		function gui:includeBox()
			local box = class(function(self)
				self.CONTROLINDEX = #GAME.GUICONTROLS+1
				self.CONTROL = interface.addBox()
				self.CONTROL = GAME.GUIDESKTOP:addControl(self.CONTROL)
				self.CONTROL:setVisible(GUI.defaultVisible)
				self.w = self.CONTROL:getDimension().w/GAME.SCALEX
				self.h = self.CONTROL:getDimension().h/GAME.SCALEY
				self.x = self.CONTROL:getPosition().x
				self.y = self.CONTROL:getPosition().y
				self.visible = GUI.defaultVisible
				self.bgColor = GUI.defaultBgColor
				self.borderColor = GUI.defaultBorderColor
				self.image = nil
				self.ROTATION = 0
				self.alpha = _OPAQUE_
			end)
			function box:exclude()
				GAME.GUIDESKTOP:removeControl(self.CONTROL)
				GAME.GUICONTROLS[self.CONTROLINDEX] = nil
				self.CONTROL = nil
			end
			function box:setImageRotation(r)
				r = r or ERROR()
				self.ROTATION = tonumber(r)
				self.CONTROL:setImageRotation(self.ROTATION)
			end
			function box:getImageRotation()
				return self.ROTATION
			end
			function box:update()
				self.CONTROL.sX = GAME.SCALEX
				self.CONTROL.sY = GAME.SCALEY
				self.CONTROL:setAlpha(self.alpha)
				self.CONTROL:setImage(GAME:RESOURCE(self.image))
				self.CONTROL:setDimension({self.w/GAME.SCALEX, self.h/GAME.SCALEY})
				self.CONTROL:setPosition({self.x/GAME.SCALEX, self.y/GAME.SCALEY})
				self.CONTROL:setVisible(self.visible)
				self.CONTROL:setBgColor(self.bgColor)
				self.CONTROL:setBorderColor(self.borderColor)
			end
			local obj = box()
			GAME.GUICONTROLS[obj.CONTROLINDEX] = obj
			return obj
		end
		self.GUICLASS = true
		return gui()
	end
	function game:includeTimer()
		timer = class(function(self)
			self.INDEX = #GAME.TIMERS+1
			self.TIME = -1
			self.delay = 100
			self.paused = true
			self.onTick = function(self) end
		end)
		function timer:start()
			self.paused = false
			self.TIME = self.delay
		end
		function timer:stop()
			self.paused = false
			self.TIME = -1
		end
		function timer:pause()
			self.paused = true
		end
		function timer:resume()
			self.paused = false
		end
		function timer:running()
			if not self.paused and self.TIME>-1 then
				return _YES_
			else
				return _NO_
			end
		end
		function timer:update()
			if self.delay<0 then
				self.paused = true
			end
			if not self.paused and self.TIME>-1 then
				self.TIME = self.TIME-1
				if self.TIME<=0 then
					self.TIME = self.delay
					self.onTick()
					GAME:EVENT('onTimerTick', self)
				end
			end
		end
		function timer:exclude()
			GAME.TIMERS[self.INDEX] = nil
			self.TIME = -1
			self.delay = 100
			self.paused = true
		end
		GAME.TIMERS[#GAME.TIMERS+1] = timer()
		return GAME.TIMERS[#GAME.TIMERS]
	end
	function game:playSound(audio, loop)
		loop = loop or 1
		self.SOUNDS[#self.SOUNDS+1] = GAME:RESOURCE(audio) or ERROR('Sound Not Found ['..audio..']')
		self.SOUNDS[#self.SOUNDS]:setVolume(GAME.defaultSoundVolume) self.SOUNDS[#self.SOUNDS]:play(loop)
		return self.SOUNDS[#self.SOUNDS]
	end
	function game:copyImage(image)
		image = GAME:RESOURCE(image) or ERROR('Image Not Found ['..image..']')
		return {{render=image, w=image:getWidth(), h=image:getHeight(), rect={0, 0, image:getWidth(),image:getHeight()}}}
	end
	function game:cutImage(image, block, mn, mx)
		image = GAME:RESOURCE(image) or ERROR('Image Not Found ['..image..']')
		block = block or ERROR()
		if block[1] > image:getWidth() then ERROR() end
		block[2] = block[2] or block[1]
		if block[2] > image:getHeight() then ERROR() end
		local sepX, sepY = 0, 0
		if block[3] then
			block[4] = block[4] or block[3]
			sepX, sepY = block[3], block[4]
		end
		local r = {}
		for y=0, image:getHeight()-1, block[2]+sepY do
			for x=0, image:getWidth()-1, block[1]+sepX do
				local m = image
				r[#r+1] = { render=m, w=block[1], h=block[2], rect={x, y, block[1], block[2]} }
			end
		end
		if #r==0 then return end
		local final = {}
		if type(mn)=='table' then
			for i=1, #mn do
				if type(mn[i])~='number' then ERROR() end
				final[#final+1] = r[i]
			end
		elseif type(mn)=='number' then
			if mn<1 then mn = 1 end
			mx = mx or mn
			if mx<mn then ERROR() end
			for i=mn, mn+(mx-mn) do
				final[#final+1] = r[i]
			end
		elseif type(mn)=='nil' then
			final = r
		else
			ERROR()
		end
		return final
	end
	function game:includeSprite(image, tileSize)
		local sprite = class(function(self)
			self.TYPE = _SPRITE_
			self.ID = #GAME.SPRITES+1
			self.TIME = 0
			self.INSTINDEX = -1
			self.INSTPARK = nil
			self.INDEX = 1
			self.RENDER = nil
			self.IMAGE = nil
			self.TILESIZE = {}
			self.tileSize = {}
			self:setImage(image, tileSize)
			self.tileImage = image
			self.values = {}
			self.var1 = nil	self.var2 = nil	self.var3 = nil	self.var4 = nil	self.var5 = nil
			self.name = 'sprite'..tostring(self.ID)
			self.animations = {}
			self.animation = nil
			self.imageIndex = 0
			self.imageSpeed = 0
			self.alpha = _OPAQUE_
			self.solid = false
			self.visible = true
			self.x = GAME.W/2 self.xSpeed = 0
			self.y = GAME.H/2 self.ySpeed = 0
			self.wSpeed = 0 self.hSpeed = 0
			self.w = self.IMAGE[1].w self.h = self.IMAGE[1].h
			self.r = 0 self.rSpeed = 0 self.cX = 0 self.cY = 0
			self.bX = 0 self.bY = 0 self.bW = self.w self.bH = self.h
			self.layer = 0
			self.onDie = function() end
			self.onDrop = function() end
			self.onUpdate = function() end
			self.onAnimationEnd = function() end
			self.killed = _NO_
		end)
		function sprite:setImage(tI, tS)
			if tS then
				if type(tS)=='number' then
					tS = { tS, tS }
				elseif type(tileSize)=='table' and #tileSize==1 then
					tS = { tS[1], tS[1] }
				end
				local function correction(tileBlock)
					for i=1, 4 do
						if type(tileBlock[i])~='number' then
							tileBlock[i] = 0
						end
					end
					return tileBlock
				end
				tS = correction(tS)
				tS = { tS[1], tS[2], tS[3], tS[4]}
				self.IMAGE = game:cutImage(tI, tS)
				self.TILESIZE = tS
				self.tileSize = self.TILESIZE
			else
				self.IMAGE = game:copyImage(tI)
				self.TILESIZE = { 1, 1, self.IMAGE[1].w, self.IMAGE[1].h }
				self.tileSize = self.TILESIZE
			end
		end
		function sprite:exclude()
			for i=1, #GAME.SPRITES do
				if self==GAME.SPRITES[i] then
					GAME.SPRITES[i]=_
					self = nil
				end
			end
		end
		function sprite:isFamily(spr)
			if spr.TYPE ~= _SPRITE_ and spr.TYPE ~= _INSTANCE_ then
				return false
			end
			if self.ID==spr.ID then
				return true
			else
				return false
			end
		end
		function sprite:duplicate()
			local r = sprite()
			if self.TYPE ~= _SPRITE_ then
				ERROR('Sprite Invalid')
			end
			r.TIME = self.TIME
			r.INDEX = self.INDEX
			r.RENDER = self.RENDER
			r.IMAGE = self.IMAGE
			r.ID = self.ID
			r.TILESIZE = self.TILESIZE
			r.tileSize = self.tileSize
			r.tileImage = self.tileImage
			r.animations = self.animations
			r.animation = self.animation
			r.imageIndex = self.imageIndex
			r.imageSpeed = self.imageSpeed
			r.values = self.values
			r.name = self.name
			r.alpha = self.alpha
			r.solid = self.solid
			r.visible = self.visible
			r.x = self.x r.xSpeed = self.xSpeed
			r.y = self.y r.ySpeed = self.ySpeed
			r.wSpeed = self.wSpeed r.hSpeed = self.hSpeed
			r.w = self.w r.h = self.h
			r.r = self.r r.rSpeed = self.rSpeed r.cX = self.cX r.cY = self.cY
			r.bX = self.bX r.bY = self.bY r.bW = self.bW r.bH = self.bH
			r.layer = self.layer
			r.onDie = self.onDie
			r.onDrop = self.onDrop
			r.onUpdate = self.onUpdate
			r.onAnimationEnd = self.onAnimationEnd
			r.var1=self.var1 r.var2=self.var2 r.var3=self.var3 r.var4=self.var4 r.var5=self.var5
			r.killed = self.killed
			return r
		end
		function sprite:render()
			local r = {}
			r[1]=self.x
			r[2]=self.y
			if self.INSTPARK then
				r[1] = r[1]-self.INSTPARK.CAMERA.x
				r[2] = r[2]-self.INSTPARK.CAMERA.y
			end
			r.rect=self.IMAGE[self.INDEX].rect
			if self.RENDER then
				self.RENDER:render(r)
			end
		end
		function sprite:check(park)
			if self.TYPE==_INSTANCE_ then
				local a = park.MAP
				local tW, tH = park.TILESIZE[3], park.TILESIZE[4]
				self.x = self.x+(self.xSpeed)
				self.y = self.y+(self.ySpeed)
				for y=1, #a do
					for x=1, #a[y] do
						if a[y][x]>0 then
							if	(self.x+self.bX<=x*tW and self.x+self.bX+self.bW>=((x-1)*tW)) and
								(self.y+self.bY<=y*tH and self.y+self.bY+self.bH>=((y-1)*tH)) then
								if park.solid and self.solid then
									self.x = self.x-(self.xSpeed)
									self.y = self.y-(self.ySpeed)
								end
								local kk = GAME:EVENT('onSpriteCollide', self, park)
								if kk==_INVERT_ then
									self.xSpeed = -self.xSpeed
									self.ySpeed = -self.ySpeed
								elseif kk==_BOUNCE_ then
									if self.y+self.bY>=y*tH or self.y+self.bY+self.bH<=((y-1)*tH) then
										self.ySpeed = -self.ySpeed
									elseif self.x+self.bX>=x*tW or self.x+self.bX+self.bW<=((x-1)*tW) then
										self.xSpeed = -self.xSpeed
									end
								end
							end
						end
					end
				end
				local s = park.INSTANCES
				for i=1, #s do
					local b = s[i]
					if b~=nil and b~=self and b~=_ then
						if	(self.x+self.bX<=b.x+b.bX+b.bW and self.x+self.bX+self.bW>=b.x+b.bX) and
							(self.y+self.bY<=b.y+b.bY+b.bH and self.y+self.bY+self.bH>=b.y+b.bY) and
							(self.xSpeed~=0 or self.ySpeed~=0) then
							if self.solid and b.solid then
								self.x = self.x-(self.xSpeed)
								self.y = self.y-(self.ySpeed)
							end
							local kk = GAME:EVENT('onSpriteCollide', self, b)
							if kk==_BACK_ then
								self.xSpeed = -self.xSpeed
								self.ySpeed = -self.ySpeed
							elseif kk==_BOUNCE_ then
								if self.x+self.bX>=b.x+b.bX+b.bW or self.x+self.bX+self.bW<=b.x+b.bX then
									self.xSpeed = -self.xSpeed
								elseif self.y+self.bY>=b.y+b.bY+b.bH or self.y+self.bY+self.bH<=b.y+b.bY then
									self.ySpeed = -self.ySpeed
								end
							end
						end
					end
				end
				if	(self.x+self.bX+self.bW)>=park.w or (self.x+self.bX)<=park.x or
					(self.y+self.bY+self.bH)>=park.h or (self.y+self.bY)<=park.y then
					local t = GAME:EVENT('onSpriteQuit', self)
					if t==_STOP_ then
						self.x = self.x-(self.xSpeed)
						self.y = self.y-(self.ySpeed)
					elseif t==_INVERT_ then
						if (self.x+self.bX)>=park.w and self.xSpeed>0 then
							self.x = park.x-self.w
						elseif (self.x+self.bX+self.bW)<=park.x and self.xSpeed<0 then
							self.x = park.w
						elseif (self.y+self.bY)>=park.h and self.ySpeed>0 then
							self.y = park.y-self.h
						elseif (self.y+self.bY+self.bH)<=park.y and self.ySpeed<0 then
							self.y = park.h
						end
					elseif t==_KILL_ then
						if	((self.x+self.bX)>=park.w and self.xSpeed>0) or
							((self.x+self.bX+self.bW)<=park.x and self.xSpeed<0) or
							((self.y+self.bY)>=park.h and self.ySpeed>0) or
							((self.y+self.bY+self.bH)<=park.y and self.ySpeed<0) then
							self:kill()
						end
					end
				end
			end
		end
		function sprite:kill()
			if self.TYPE ~= _INSTANCE_ then
				ERROR('Sprite Method Invalid')
			end
			if self.INSTPARK.TYPE == _EMPTY_ then
				return _ABORT_
			end
			self.onDie(self)
			local ok = GAME:EVENT('onSpriteDie', self)
			if ok~=_ABORT_ then
				self.killed = _YES_
				self.INSTPARK.INSTANCES[self.INSTINDEX] = 0
			end
		end
		function sprite:update()
			if GAME.RUNNING then
				self.w = self.w + (self.wSpeed/_SECOND_)
				self.h = self.h + (self.hSpeed/_SECOND_)
				self.TIME = self.TIME + 1
				if #self.IMAGE>1 then
					if self.animation==nil then
						if self.imageSpeed > 0 then
							if self.TIME > (self.imageSpeed*_SECOND_) then
								self.TIME = 0
								self.imageIndex = self.imageIndex + 1
								if self.imageIndex > #self.IMAGE-1 then
									self.imageIndex = 0
									self.onAnimationEnd(self)
									GAME:EVENT('onSpriteAnimationEnd', self, _EMPTY_)
								end
								self.INDEX = self.imageIndex+1
							end
						end
						if self.imageIndex > #self.IMAGE-1 or self.imageIndex < 0 then
							ERROR('Image Index Invalid')
						else
							self.INDEX = self.imageIndex+1
						end
					elseif type(self.animations[self.animation])=='table' then
						if #self.animations[self.animation]==0 then ERROR() end
						if self.imageSpeed > 0 then
							if self.TIME > (self.imageSpeed*_SECOND_) then
								self.TIME = 0
								self.imageIndex = self.imageIndex+1
								if self.imageIndex > #self.animations[self.animation]-1 then
									self.imageIndex = 0
									self.onAnimationEnd(self)
									GAME:EVENT('onSpriteAnimationEnd', self, self.animation)
								end
							else
								self.INDEX = self.animations[self.animation][self.imageIndex+1]+1
							end
						end
					end
				elseif #self.IMAGE==0 then
					ERROR()
				end
				if self.INDEX < 0 then
					ERROR('Image Index Invalid')
				end
				local sX, sY
				if self.RENDER==nil then
					sX = 1 sY = 1
				else
					sX = self.RENDER:getScaleX()
					sY = self.RENDER:getScaleY()
				end
				local img = self.IMAGE[self.INDEX]
				if tostring(self.cX)==_CENTER_ then
					self.cX = img.w/2
				end
				if tostring(self.cY)==_CENTER_ then
					self.cY = img.h/2
				end
				img.render:setScaleX(self.w/img.w)
				img.render:setScaleY(self.h/img.h)
				img.render:setCenter(self.cX, self.cY)
				self.RENDER = img.render
				if self.visible then
					self.RENDER:setAlpha(self.alpha)
				else
					self.RENDER:setAlpha(_TRANSPARENT_)
				end
				self.r = self.r + (self.rSpeed/_SECOND_)
				self.RENDER:setRotation(self.r)
			else
				local sX, sY
				if self.RENDER==nil then
					sX = 1 sY = 1
				else
					sX = self.RENDER:getScaleX()
					sY = self.RENDER:getScaleY()
				end
				if self.RENDER==nil then
					self.RENDER = scrupp.addImage('game2d/sprite.png')
				end
				local img = self.IMAGE[self.INDEX]
				if tostring(self.cX)==_CENTER_ then
					self.cX = img.w/2
				end
				if tostring(self.cY)==_CENTER_ then
					self.cY = img.h/2
				end
				img.render:setScaleX(self.w/img.w)
				img.render:setScaleY(self.h/img.h)
				img.render:setCenter(self.cX, self.cY)
				self.RENDER = img.render
				if self.visible then
					self.RENDER:setAlpha(self.alpha)
				else
					self.RENDER:setAlpha(_TRANSPARENT_)
				end
				self.r = self.r + (self.rSpeed/_SECOND_)
				self.RENDER:setRotation(self.r)
			end
		end
		self.SPRITES[#self.SPRITES+1] = sprite()
		return self.SPRITES[#self.SPRITES]
	end
	function game:includePark(tI, tS)
		local PARK = nil
		local park = class(function(self)
			self.TYPE = _PARK_
			self.PARKINDEX = #GAME.PARKS+1
			self.INSTANCES = {}
			self.CAMERA = {x=0, y=0, w=GAME.W, h=GAME.H}
			self.CAMERACLASS = false
			self.PARKS = {}
			self.ANIMATIONS = {}
			self.SQUARES = {}
			self.tileMap = {}
			self.alpha = _OPAQUE_
			self.MAP = self.tileMap
			self.backImage = nil
			self.backType = _NORMAL_
			self.backAlpha = _OPAQUE_
			self.backColor = _WHITE_
			if tI==nil then
				ERROR('Image Required')
			end
			if tS then
				if type(tS)=='number' then
					tS = { tS, tS }
				elseif type(tileSize)=='table' and #tileSize==1 then
					tS = { tS[1], tS[1] }
				end
				local function correction(tileBlock)
					for i=1, 4 do
						if type(tileBlock[i])~='number' then
							tileBlock[i] = 0
						end
					end
					return tileBlock
				end
				tS = correction(tS)
				tS = { tS[1], tS[2], tS[3], tS[4]}
				self.IMAGE = game:cutImage(tI, tS) or ERROR('Image Not Found ['..tI..']')
				self.tileSize = { 1, 1, tS[1], tS[2] }
				self.TILESIZE = table_duplicate(self.tileSize)
			else
				ERROR('Tile Size Required')
			end
			self.w = GAME.W
			self.h = GAME.H
			self.W = self.w
			self.H = self.h
			self.x = 0
			self.y = 0
			self.solid = false
			self.visible = true
			self.onUpdate = function() end
			PARK = self
		end)
		function park:isFamily(prk)
			if prk==nil then
				return false
			end
			if prk.TYPE ~= _PARK_ then
				return false
			end
			if self.PARKINDEX==prk.PARKINDEX then
				return true
			else
				return false
			end
		end
		function park:exclude()
			for i=1, #GAME.PARKS do
				if self==GAME.PARKS[i] then
					GAME.PARKS[i]=_
					self = nil
				end
			end
		end
		function park:update()
			local Xlen = 0
			for i=1, #self.tileMap do
				local xLen2 = #self.tileMap[i]
				if xLen2>Xlen then
					Xlen = xLen2
				end
			end
			self.W = self.TILESIZE[3]*Xlen
			self.H = self.TILESIZE[4]*(#self.tileMap)
			for i=1, #self.ANIMATIONS do
				if self.ANIMATIONS[i] then
					self.ANIMATIONS[i]:update()
				end
			end
			for i=1, #self.PARKS do
				for j=1, #self.PARKS[i].park.ANIMATIONS do
					if self.PARKS[i].park.ANIMATIONS[j] then
						self.PARKS[i].park.ANIMATIONS[j]:update()
					end
				end
			end
			self.MAP = self:tileMap2Map()
			if self.visible then
				local r = {}
				local s = {}
				for i=1, #self.PARKS do
					if self.PARKS[i] then
						r[#r+1]={obj=self.PARKS[i].park, l=self.PARKS[i].layer}
					end
				end
				for i=1, #self.INSTANCES do
					if self.INSTANCES[i]~=nil and self.INSTANCES[i]~=_ then
						s[#s+1]={obj=self.INSTANCES[i], l=self.INSTANCES[i].layer}
					end
				end
				local lMin, lMax = 0, 0
				for i=1, #r do
					if r[i].l<lMin then lMin=r[i].l
					elseif r[i].l>lMax then lMax=r[i].l
					end
				end
				for i=1, #s do
					if s[i].l<lMin then lMin=s[i].l
					elseif s[i].l>lMax then lMax=s[i].l
					end
				end
				local u = (lMin-lMax-1)*-1
				local function renderPImgs(z)
					local j = {}
					for i=1, #r do
						if r[i].l==z then
							j[#j+1]=r[i].obj
						end
					end
					for i=1, #j do
						j[i]:render(_PIMG_)
					end
				end
				local function renderPark()
					self:render()
				end
				local function renderSprites(z)
					local j = {}
					for i=1, #s do
						if s[i].l==z then
							j[#j+1]=s[i].obj
						end
					end
					for i=1, #j do
						j[i]:update()
						if GAME.RUNNING then
							j[i].onUpdate(j[i])
							GAME:EVENT('onSpriteUpdate', j[i])
							j[i]:check(self)
						end
						if	(j[i].x+j[i].w>=self.CAMERA.x and j[i].x<=self.CAMERA.x+self.CAMERA.w) and
							(j[i].y+j[i].h>=self.CAMERA.y and j[i].h<=self.CAMERA.y+self.CAMERA.h) then
							j[i]:render()
						end
					end
				end
				local f = {color = self.backColor, antialiasing = false, connect = true, fill=true}
				f[#f+1] = self.x
				f[#f+1] = self.y
				f[#f+1] = self.x+self.w
				f[#f+1] = self.y
				f[#f+1] = self.x+self.w
				f[#f+1] = self.y+self.h
				f[#f+1] = self.x
				f[#f+1] = self.y+self.h
				f[#f+1] = self.x
				f[#f+1] = self.y
				scrupp.draw(f)
				if self.backImage then
					local d = GAME:RESOURCE(self.backImage) or ERROR()
					d:setAlpha(self.backAlpha)
					d:setScale(1*GAME.SCALEX, 1*GAME.SCALEY)
					if self.backType==_NORMAL_ then
						d:render(self.x, self.y)
					elseif self.backType==_CENTER_ then
						d:render(((self.w/2)-(d:getWidth()/2)),((self.h/2)-(d:getHeight()/2)))
					elseif self.backType==_STRETCHED_ then
						d:setScale(PARK.w/d:getWidth(), PARK.h/d:getHeight())
						d:render(self.x, self.y)
					elseif self.backType==_TILED_ then
						for vy=0, self.y+self.h, d:getHeight()-2 do
							for vx=0, self.x+self.w, d:getWidth()-2 do
								if	(vx+d:getWidth()>=self.CAMERA.x and vx<=self.CAMERA.x+self.CAMERA.w) and
									(vy+d:getHeight()>=self.CAMERA.y and vy<=self.CAMERA.y+self.CAMERA.h) then
									local f = {}
									f[1] = vx-self.CAMERA.x
									f[2] = vy-self.CAMERA.y
									f.rect = {1, 1, d:getWidth(), d:getHeight() }
									d:render(f)
								end
							end
						end
					else
						ERROR()
					end
				end
				for i=1, u do
					local curL = lMin+i-1
					if curL==0 then
						renderPImgs(curL)
						renderPark()
						renderSprites(curL)
					else
						renderPImgs(curL)
						renderSprites(curL)
					end
				end
			end
		end
		function park:render(t)
			if t==_PIMG_ then
				self.MAP = self:tileMap2Map()
			end
			if self.visible then
				for y=1,#self.MAP do
					for x=1,#self.MAP[y] do
						if self.IMAGE[self.MAP[y][x]] then
							local r = {}
							r[1]=self.x+((self.TILESIZE[3]*x)-self.TILESIZE[3])
							r[2]=self.y+((self.TILESIZE[4]*y)-self.TILESIZE[4])
							r.rect=self.IMAGE[self.MAP[y][x]].rect
							self.IMAGE[self.MAP[y][x]].render:setAlpha(self.alpha)
							local vx, vy = r[1], r[2]
							if	(vx+self.TILESIZE[3]>=self.CAMERA.x and vx<=self.CAMERA.x+self.CAMERA.w) and
								(vy+self.TILESIZE[4]>=self.CAMERA.y and vy<=self.CAMERA.y+self.CAMERA.h) then
								r[1] = r[1]-self.CAMERA.x
								r[2] = r[2]-self.CAMERA.y
								self.IMAGE[self.MAP[y][x]].render:render(r)
							end
						end
					end
				end
			end
		end
		function park:tileMap2Map()
			local a = self.tileMap
			local r = table_duplicate(a)
			for y=1, #a do
				for x=1, #a[y] do
					if type(a[y][x])=='table' then
						if a[y][x].TYPE==_SQUARE_ then
							r[y][x]=a[y][x]:get(a,y,x)
						elseif a[y][x].TYPE==_ANIMATION_ then
							local ok = false
							for i=1, #self.ANIMATIONS do
								if self.ANIMATIONS[i]==a[y][x] then
									ok = true
								end
							end
							if ok then
								r[y][x]=a[y][x]:get()
							else
								r[y][x]=0
							end
						else ERROR()
						end
					elseif type(a[y][x])=='nil' then
						r[y][x]=0
					elseif type(a[y][x])=='number' then
						if a[y][x]<0 then ERROR() end
						r[y][x]=a[y][x]
					else ERROR()
					end
				end
			end
			return r
		end
		function park:includeParkImage(p, l)
			l = tonumber(l) or -1
			local ok = false
			for i=1, #GAME.PARKS do
				if p==GAME.PARKS[i] then
					ok = true
				end
			end
			if ok then
				for i=1, #self.PARKS do
					if p==self.PARKS[i].park then
						ERROR('Park Image already exists in this Park Class')
					end
				end
				local pimg = class(function(self)
					self.INDEX = #PARK.PARKS+1
				end)
				function pimg:exclude()
					PARK.PARKS[self.INDEX]=nil
				end
				PARK.PARKS[#PARK.PARKS+1]= { park = p, layer = l}
				return pimg()
			else
				ERROR('Park Not Found')
			end
		end
		function park:exclude()
			GAME.PARKS[self.PARKINDEX] = nil
			self.INSTANCES = {}
			self.ANIMATIONS = {}
			self.SQUARES = {}
			self.tileMap = nil
			self.backImage = nil
			self.backType = _NORMAL_
			self.backAlpha = _OPAQUE_
			self.backColor = _WHITE_
		end
		function park:camera()
			if self.CAMERACLASS then
				ERROR('Camera class already exists in park class')
			end
			local camera = class()
			function camera:moveTo(x, y)
				PARK.CAMERA.x = tonumber(PARK.CAMERA.x)
				PARK.CAMERA.y = tonumber(PARK.CAMERA.y)
			end
			function camera:x(x)
				if x then
					PARK.CAMERA.x=tonumber(x)
				else
					return PARK.CAMERA.x
				end
			end
			function camera:y(y)
				if y then
					PARK.CAMERA.y=tonumber(y)
				else
					return PARK.CAMERA.y
				end
			end
			function camera:w(w)
				if w then
					PARK.CAMERA.w=tonumber(w)
				else
					return PARK.CAMERA.w
				end
			end
			function camera:h(h)
				if h then
					PARK.CAMERA.h=tonumber(h)
				else
					return PARK.CAMERA.h
				end
			end
			self.CAMERACLASS = true
			return camera()
		end
		function park:updateCamera()
			if self.CAMERA.w<math.sqrt(GAME.W) then self.CAMERA.w = math.sqrt(GAME.W)
			elseif self.CAMERA.w>PARK.w then self.CAMERA.w=PARK.w GAME.SCALEX=1 end
			if self.CAMERA.h<math.sqrt(GAME.H) then self.CAMERA.h = math.sqrt(GAME.H)
			elseif self.CAMERA.h>PARK.h then self.CAMERA.h=PARK.h GAME.SCALEY=1 end
			if self.CAMERA.x<self.x then self.CAMERA.x=self.x
			elseif self.CAMERA.x+self.CAMERA.w>self.x+self.w then self.CAMERA.x = (self.x+self.w)-self.CAMERA.w end
			if self.CAMERA.y<self.y then self.CAMERA.y=self.y
			elseif self.CAMERA.y+self.CAMERA.h>self.y+self.h then self.CAMERA.y = (self.y+self.h)-self.CAMERA.h end
			local s1, s2 = GAME.SCALEX, GAME.SCALEY
			GAME.SCALEX, GAME.SCALEY = (self.w/self.CAMERA.w),(self.h/self.CAMERA.h)
			if GAME.SCALEX~=s1 or GAME.SCALEY~=s2 then
				scrupp.resetView()
				scrupp.scaleView(GAME.SCALEX, GAME.SCALEY)
			end
		end
		function park:includeAnimation()
			local anim = class(function(self)
				self.TYPE = _ANIMATION_
				self.INDEX = #PARK.ANIMATIONS+1
				self.TIME = 0
				self.RENDER = nil
				self.animation = {}
				self.imageSpeed = 1
				self.imageIndex = 0
			end)
			function anim:exclude()
				PARK.ANIMATIONS[self.INDEX]=nil
				self.animation = {}
			end
			function anim:get()
				return self.imageIndex+1
			end
			function anim:update()
				if self.imageIndex > #self.animation-1 or self.imageIndex < 0 then
					ERROR('Image Index Invalid')
				end
				if GAME.RUNNING then
					self.TIME = self.TIME + 1
					if self.imageSpeed<0 then
						ERROR()
					end
					if #self.animation>0 then
						if self.TIME>self.imageSpeed*(_SECOND_) then
							self.TIME = 0
							self.imageIndex = self.imageIndex+1
							if self.imageIndex>#self.animation-1 then
								self.imageIndex = 0
							end
						end
					else
						if self.TIME>self.imageSpeed*(_SECOND_) then
							self.TIME = 0
							self.imageIndex = self.imageIndex+1
							if self.imageIndex>#PARK.IMAGE-1 then
								self.imageIndex = 0
							end
						end
					end
					if #PARK.IMAGE>1 then
						self.RENDER = PARK.IMAGE[self.imageIndex+1]
					else
						self.RENDER = PARK.IMAGE[1]
					end
				end
			end
			PARK.ANIMATIONS[#PARK.ANIMATIONS+1] = anim()
			return PARK.ANIMATIONS[#PARK.ANIMATIONS]
		end
		function park:includeSquare()
			local square = class(function(self)
				self.TYPE = _SQUARE_
				self.INDEX = #PARK.SQUARES+1
				self.OK = true
				self.tileMap = {}
				self.alpha = _OPAQUE_
			end)
			function square:exclude()
				PARK.SQUARES[self.INDEX]=nil
				self.tileMap = {}
				self.OK = false
			end
			function square:get(k, y, x)
				local p = table_duplicate(self.tileMap)
				local w = 0
				local h = #p
				for i=1, #p do
					if #p[i]>w then w=#p[i] end
				end
				for j=1, #k do
					for h=1, #k[j] do
						if k[j][h]==0 then
							k[j][h]=_
						end
					end
				end
				local lQ
				if x-1<1 then
					lQ = _
				else
					lQ = k[y][x-1]
				end
				local rQ
				if x+1>#k[y] then
					rQ = _
				else
					rQ =  k[y][x+1]
				end
				local uQ
				if y-1<1 then
					uQ = _
				else
					uQ = k[y-1][x]
				end
				local dQ
				if y+1>#k then
					dQ = _
				else
					dQ = k[y+1][x]
				end
				if type(lQ)=='number' or lQ==_ then
					lQ = false
				elseif type(lQ)=='table' then
					if lQ==self then
						lQ = true
					else
						lQ = false
					end
				else ERROR() end
				if type(rQ)=='number' or rQ==_ then
					rQ = false
				elseif type(rQ)=='table' then
					if rQ==self then
						rQ = true
					else
						rQ = false
					end
				else ERROR() end
				if type(uQ)=='number' or uQ==_ then
					uQ = false
				elseif type(uQ)=='table' then
					if uQ==self then
						uQ = true
					else
						uQ = false
					end
				else ERROR() end
				if type(dQ)=='number' or dQ==_ then
					dQ = false
				elseif type(dQ)=='table' then
					if dQ==self then
						dQ = true
					else
						dQ = false
					end
				else ERROR() end
				local function pull(a, b)
					if a=='?' then
						a = random_integer(2,w-1)
					elseif a=='>' then
						a = w
					elseif a=='<' then
						a = 1
					else ERROR()
					end
					if b=='?' then
						b = random_integer(2,h-1)
					elseif b=='>' then
						b = h
					elseif b=='<' then
						b = 1
					else ERROR()
					end
					if self.OK==false then
						return 0
					else
						if b==0 or a==0 then
							return p[1][1]
						end
						return p[b][a]
					end
				end
				if lQ then
					if uQ then
						if dQ then
							if rQ then
								return pull('?','?')
							else
								return pull('>','?')
							end
						else
							if rQ then
								return pull('?','>')
							else
								return pull('>','>')
							end
						end
					else
						if rQ then
							return pull('?', '<')
						else
							return pull('>', '<')
						end
					end
				else
					if uQ then
						if dQ then
							return pull('<','?')
						else
							return pull('<','>')
						end
					else
						return pull('<','<')
					end
				end
			end
			PARK.SQUARES[#PARK.SQUARES+1] = square()
			return PARK.SQUARES[#PARK.SQUARES]
		end
		function park:dropSprite(spr, x, y)
			if type(spr)~='table' then ERROR() end
			local ok = false
			for i=1, #GAME.SPRITES do
				if spr==GAME.SPRITES[i] and GAME.SPRITES[i]~=_ then
					ok = true
				end
			end
			if ok then
				x = x or spr.x
				y = y or spr.y
				local r = spr:duplicate()
				r.x = tonumber(x)
				r.y = tonumber(y)
				r.TYPE = _INSTANCE_
				r.INSTINDEX = #self.INSTANCES+1
				r.INSTPARK = self
				self.INSTANCES[r.INSTINDEX] = r
				self.INSTANCES[#self.INSTANCES].onDrop(self.INSTANCES[#self.INSTANCES])
				GAME:EVENT('onSpriteDrop', self.INSTANCES[#self.INSTANCES])
				return self.INSTANCES[#self.INSTANCES]
			else
				ERROR('Sprite Not Found')
			end
		end
		function park:spriteDistance(spr1, spr2)
			spr1 = spr1 or ERROR()
			spr2 = spr2 or ERROR()
			if type(spr1)~='table' or type(spr2)~='table' then
				ERROR()
			end
			if spr1.TYPE~=_INSTANCE_ or spr2.TYPE~=_INSTANCE_  then
				ERROR('Dropped Sprite Required')
			end
			local ok = false
			for i=1, #self.INSTANCES do
				if type(self.INSTANCES[i])~=type(0) then
					if self.INSTANCES[i].INSTPARK==spr1.INSTPARK then
						ok = true
					end
				end
			end
			if not ok then
				ERROR('Dropped Sprite Required')
			end
			ok = false
			for i=1, #self.INSTANCES do
				if type(self.INSTANCES[i])~=type(0) then
					if self.INSTANCES[i].INSTPARK==spr2.INSTPARK then
						ok = true
					end
				end
			end
			if not ok then
				ERROR('Dropped Sprite Required')
			end
			return math.sqrt(math.pow(spr2.x-spr1.x,2)+math.pow(spr2.y-spr1.y,2))
		end
		function park:spriteNumber(t)
			if type(t)~='table' and type(t)~='nil' then
				ERROR()
			end
			if t then
				if t.TYPE then
					t = { t }
				end
			end
			if t==nil then return #self.INSTANCES end
			for i=1, #t do
				if t[i].TYPE~=_INSTANCE_ and t[i].TYPE~=_SPRITE_ then
					ERROR('Sprite or Dropped Sprite Required')
				end
			end
			local n = 0
			for i=1, #self.INSTANCES do
				if type(self.INSTANCES[i])~=type(0) then
					for j=1, #t do
						if t[j].ID==self.INSTANCES[i].ID then
							n = n + 1
							break
						end
					end
				end
			end
			return n
		end
		function park:spriteNearest(spr1, t)
			if spr1.TYPE~=_INSTANCE_ then
				ERROR('Dropped Sprite Required')
			end
			local ok = false
			for i=1, #self.INSTANCES do
				if type(self.INSTANCES[i])~=type(0) then
					if self.INSTANCES[i].INSTPARK==spr1.INSTPARK then
						ok = true
					end
				end
			end
			if not ok then
				ERROR('Dropped Sprite Required')
			end
			local r, n = nil, -1
			if type(t)=='nil' then
				for i=1, #self.INSTANCES do
					local spr2 = self.INSTANCES[i]
					local u = math.sqrt(math.pow(spr2.x-spr1.x,2)+math.pow(spr2.y-spr1.y,2))
					if (u<n or n==-1) and spr2.INSTINDEX~=spr1.INSTINDEX then
						n, r = u, spr2
					end
				end
				return r
			elseif type(t)=='table' then
				if t.TYPE then
					t = { t }
				end
				for i=1, #self.INSTANCES do
					for j=1, #t do
						if type(self.INSTANCES[i])~=type(0) then
							if self.INSTANCES[i].ID==t[j].ID then
								local spr2 = self.INSTANCES[i]
								local u = math.sqrt(math.pow(spr2.x-spr1.x,2)+math.pow(spr2.y-spr1.y,2))
								if (u<n or n==-1) and spr2.INSTINDEX~=spr1.INSTINDEX then
									n, r = u, spr2
								end
							end
						end
					end
				end
				return r
			else
				ERROR()
			end
		end
		function park:spriteLongest(spr1, t)
			if spr1.TYPE~=_INSTANCE_ then
				ERROR('Dropped Sprite Required')
			end
			local ok = false
			for i=1, #self.INSTANCES do
				if type(self.INSTANCES[i])~=type(0) then
					if self.INSTANCES[i].INSTPARK==spr1.INSTPARK then
						ok = true
					end
				end
			end
			if not ok then
				ERROR('Dropped Sprite Required')
			end
			local r, n = nil, -1
			if type(t)=='nil' then
				for i=1, #self.INSTANCES do
					if type(self.INSTANCES[i])~=type(0) then
						local spr2 = self.INSTANCES[i]
						local u = math.sqrt(math.pow(spr2.x-spr1.x,2)+math.pow(spr2.y-spr1.y,2))
						if u>n and spr2.INSTINDEX~=spr1.INSTINDEX then
							n, r = u, spr2
						end
					end
				end
				return r
			elseif type(t)=='table' then
				if t.TYPE then
					t = { t }
				end
				for i=1, #self.INSTANCES do
					for j=1, #t do
						if type(self.INSTANCES[i])~=type(0) then
							if self.INSTANCES[i].ID==t[j].ID then
								local spr2 = self.INSTANCES[i]
								local u = math.sqrt(math.pow(spr2.x-spr1.x,2)+math.pow(spr2.y-spr1.y,2))
								if u>n and spr2.INSTINDEX~=spr1.INSTINDEX then
									n, r = u, spr2
								end
							end
						end
					end
				end
				return r
			else
				ERROR()
			end
		end
		self.PARKS[#self.PARKS+1] = park()
		return self.PARKS[#self.PARKS]
	end
	function game:resources()
		if self.RESOURCESCLASS then
			ERROR('Resources object already exists in game class')
		end
		local pack = class()
		function pack:load(source)
			local types = {}
			if type(source)~='string' and type(source)~='table' then ERROR('Resource Type Invalid') end
			if type(source)=='string' then
				source = { replace_char( source, '\\', '/' ) }
			end
			for i=1, #source do
				if type(source[i])=='string' then
					if source[i]=='./' or source[i]=='' or source[i]==' ' then ERROR('Resource Invalid') end
					if scrupp.isDirectory(source[i]) then
						for file in lfs.dir(source[i]) do
							if file ~= '.' and file ~= '..' and file ~= 'Thumbs.db' and file ~= 'Desktop.ini' and not scrupp.isDirectory(source[i]..file) then
								local c = string.sub(source[i], #source[i], #source[i])
								if c~='/' and c~='\\' then
									source[i] = source[i]..'/'
								end
								types = split(image_types..'|'..sound_types..'|'..font_types,'|')
								for w=1, #types do
									ext = split(file,'.') ext = string.lower(ext[#ext])
									if string.lower(types[w])==ext then
										local ok = true
										if #GAME.FILES>0 then
											for u=1, #GAME.FILES do
												if string.lower(getFilename(GAME.FILES[u]))==string.lower(file) then
													ok = false
												end
											end
										end
										if ok then
											GAME.FILES[#GAME.FILES+1] = source[i]..file
										end
									end
								end
							end
						end
					else
						types = split(image_types..'|'..sound_types..'|'..font_types,'|')
						for w=1, #types do
							ext = split(source[i],'.') ext = string.lower(ext[#ext])
							if string.lower(types[w])==ext then
								if scrupp.fileExists(source[i]) then
									local ok = true
									if #GAME.FILES>0 then
										for u=1, #GAME.FILES do
											if string.lower(getFilename(GAME.FILES[u]))==split(string.lower(source[i]),'/')[#split(string.lower(source[i]),'/')] then
												ok = false
											end
										end
									end
									if ok then
										GAME.FILES[#GAME.FILES+1] = source[i]
									end
								end
							end
						end
					end
				end
			end
		end
		function pack:unload()
			GAME.FILES = {}
		end
		self.RESOURCESCLASS = true
		return pack()
	end
	function game:update()
		return {
			render = function(dt)
				local mX, mY = self.MOUSEX, self.MOUSEY
				self.MOUSEX, self.MOUSEY = scrupp.getMousePos()
				self.MOUSEX = self.MOUSEX/self.SCALEX
				self.MOUSEY = self.MOUSEY/self.SCALEY
				if self.MOUSEX >= (self.W/self.SCALEX)-1 then self.MOUSEX = (self.W/self.SCALEX)-1 end
				if self.MOUSEY >= (self.H/self.SCALEY)-1 then self.MOUSEY = (self.H/self.SCALEY)-1 end
				self.DELTA = dt
				--KEYBOARD AND MOUSE
				local mD = getMouseDevice()
				for i=1, #mD do
					GAME:EVENT('onMouse', mD[i])
				end
				local kD = getKeyboardDevice()
				for i=1, #kD do
					GAME:EVENT('onKey', kD[i])
				end
				--BEGIN
				if GAME.RUNNING then
					GAME:EVENT('onGameUpdateBegin')
				end
				for i=1,#GAME.TIMERS do
					if GAME.TIMERS[i] then
						GAME.TIMERS[i]:update()
					end
				end
				--
				if self.PARK then
					if GAME.RUNNING then
						self.PARK.onUpdate()
						GAME:EVENT('onParkUpdate', self.PARK)
					end
					self.PARK:updateCamera()
					self.PARK:update()
				end
				--
				if GAME.RUNNING then
					GAME:EVENT('onGameUpdate')
				end
				--GUI
				if self.GUICLASS then
					for i=1, #GAME.GUICONTROLS do
						if GAME.GUICONTROLS[i]~=nil then
							GAME.GUICONTROLS[i]:update()
						end
					end
					GAME.GUIDESKTOP:update()
				end
				--END
				if GAME.RUNNING then
					GAME:EVENT('onGameUpdateEnd')
				end
				--MOUSE
				if self.MOUSE~=nil then
					if self.SPRITES[self.MOUSEINDEX]~=nil then
						self.MOUSE.x = self.MOUSEX
						self.MOUSE.y = self.MOUSEY
						self.MOUSE:update()
						self.MOUSE:render()
					else
						self.MOUSE = nil
						self.MOUSEINDEX = nil
					end
				end
				scrupp.showCursor(false)
				interface.update(self.MOUSEX, self.MOUSEY, self.W/GAME.SCALEX, self.H/GAME.SCALEY)
				if self.CURSORSHOW then
					self.CURSOR:setScale(1/self.SCALEX, 1/self.SCALEY)
					self.CURSOR:render(self.MOUSEX, self.MOUSEY)
				end
				if self.MOUSE==nil and not self.CURSORSHOW then
					self.MOUSEX = -1
					self.MOUSEY = -1
				else
					if mX~=self.MOUSEX or mY~=self.MOUSEY then
						GAME:EVENT('onMouseMove')
					end
				end
			end,
			keypressed = function(key)
				if key==_ALT_ then
					GAME.LALT = true
				elseif key==_F4_ and self.LALT then
					GAME:exit()
				end
				--GUI
				if self.GUICLASS then
					GAME.GUIDESKTOP:updateKeyPressed(key)
				end
				GAME:EVENT('onKeyPress',key)
			end,
			keyreleased = function(key)
				if key==_ALT_ then
					GAME.LALT = false
				end
				--GUI
				if self.GUICLASS then
					GAME.GUIDESKTOP:updateKeyReleased(key)
				end
				GAME:EVENT('onKeyRelease', key)
			end,
			mousepressed = function(pX, pY, mouse)
				--GUI
				if self.GUICLASS then
					GAME.GUIDESKTOP:updateMousePressed(mouse)
				end
				GAME:EVENT('onMousePress', mouse)
			end,
			mousereleased = function(pX, pY, mouse)
				--GUI
				if self.GUICLASS then
					GAME.GUIDESKTOP:updateMouseReleased(mouse)
				end
				GAME:EVENT('onMouseRelease', mouse)
			end
		}
	end
	return game()
end
