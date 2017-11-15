
display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() )
_S = {
  centerX = display.contentCenterX,
  centerY = display.contentCenterY,
  width = display.contentWidth,
  height = display.contentHeight,
  top = display.screenOriginY,
  bottom = display.viewableContentHeight - display.screenOriginY,
  left = display.screenOriginX,
  right = display.viewableContentWidth - display.screenOriginX,
  actualWidth = display.actualContentWidth, 
  actualHeight = display.actualContentHeight 
}

local composer = require( "composer" )
composer.gotoScene("scene-menu") 