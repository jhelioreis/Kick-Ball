local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
local physics = require( "physics" )
physics.start()
--physics.setDrawMode( "hybrid" ) -- enable this to see the physics boundaries
physics.setGravity( 0, 19.6 )

local createCircle -- this is a function to hold all of the circles created
local circleTable = {} -- this is a table that holds all circle objects
local circleCounter = 1 -- keep track of the number of circles on the stage
local tmr_createCircles -- a variable to keep track of the timer

local touchArea, background

local onGlobalCollision, gameOver
local btn_menu, onMenuTouch
local txt_gameOver, txt_playerScore
local scoreCounter = 0 -- track the number of successful bounces
local bounceBar -- the variable to hold the bounce bar object
local isGameOver = false -- lets us know whether or not the game is over
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene event functions

-- gameOver will be called when the game is over. Stop physics, remove objects, and display game over
gameOver = function()
  isGameOver = true
  physics.pause()
  timer.cancel(tmr_createCircles)
  for i=1,#circleTable do
    if(circleTable[i]) then display.remove(circleTable[i]) end
  end
  transition.to(txt_playerScore, {xScale=2, yScale=2})
  btn_menu.alpha = 1
  transition.to(txt_gameOver, {alpha=1})
end

-- Adicione um ponto à pontuação do jogador, atualize a pontuação e dimensione a pontuação para efeitos visuais
addToScore = function()
  scoreCounter = scoreCounter + 1
  txt_playerScore.text = scoreCounter .. " Ball"

  local tempScale = math.random(80,130) / 100
  transition.to(txt_playerScore, {xScale=tempScale, yScale=tempScale} )
end

-- Create the "circle". The circle can be any circular object. In this game, we are using a character in a circle
createCircle = function()

  transition.to(background, {xScale=1.15, yScale=1.15, time=300})
  transition.to(background, {xScale=1, yScale=1, delay=300})

  local circle = display.newImageRect("images/circle.png", 125, 125)
    circle.x = 450; circle.y = 100
    circle.alpha = 0
    circle.myName = "circle"
    physics.addBody( circle, { density=1.0, friction=0, bounce = 0.9, radius=60 } )

    local leftOrRight
    if(math.random(1,2) == 1) then
      leftOrRight = -1
    else
      leftOrRight = 1
    end
    circle:setLinearVelocity(((math.random(5,13))*15) * leftOrRight, 0 )

    transition.to(circle, {alpha=1, time=400})

  return circle
end

-- This gets called when two physics objects collide with each other.
onGlobalCollision = function(event)
    local obj1 = event.object1
    local obj2 = event.object2

    if ( event.phase == "ended" ) then
      if( obj1.myName == "bar" and obj2.myName == "circle" and isGameOver == false) then

        timer.performWithDelay(1, function()
          if(isGameOver == false) then
            obj2:applyLinearImpulse( math.random(-30,30), math.random(-30,-10), obj1.x, obj1.y)
          end
        end, 1)

        local rotateTo = obj2.rotation + math.random(-50,50)
        transition.to(obj2, {rotation=rotateTo} )

        addToScore()
      end

      if(obj1.myName == "touchArea" and obj2.myName == "circle") then
        gameOver()
      end
      if(obj1.myName == "circle" and obj2.myName == "touchArea") then
        gameOver()
      end
    end
end

-- Finally, send the player back to the menu
onMenuTouch = function(event)
  if ( "ended" == event.phase ) then
    composer.gotoScene("scene-menu", "fade")
  end
end
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view

    -- Display a background
    background = display.newImageRect(sceneGroup, "images/background1.png", _S.actualWidth, _S.actualHeight)
      background.x = _S.centerX; background.y = _S.centerY

    -- Create touch area that will respond to player drag and will call game over if a ball collides with the touch area
    touchArea = display.newRect(sceneGroup, 0, 0, _S.actualWidth, 200)
      touchArea.x = _S.centerX
      touchArea.y = _S.bottom - (touchArea.height * 0.5)
      touchArea:setFillColor(0,0,0,0.25)
      touchArea.myName = "touchArea"
      physics.addBody( touchArea )
      touchArea.gravityScale = 0
      touchArea.isSensor = true

    -- Text objects for instruction: txt_touchInstructions, txt_playerScore, txt_gameOver
    local txt_touchInstructions = display.newText(sceneGroup, "Arraste aqui para mover", 0, 0, "ChunkFive", 32)
      txt_touchInstructions.x = _S.centerX
      txt_touchInstructions.y = touchArea.y

    txt_playerScore = display.newText(sceneGroup, "0 Ball", 0, 0, "ChunkFive", 48)
      txt_playerScore.x = _S.centerX
      txt_playerScore.y = _S.centerY * 0.5

    txt_gameOver = display.newText(sceneGroup, "Voçê Perdeu", 0, 0, "ChunkFive", 100)
      txt_gameOver.x = _S.centerX
      txt_gameOver.y = txt_playerScore.y - (txt_playerScore.height * 2)
      txt_gameOver.alpha = 0

    -- Create the boundaries: leftWall, rightWall, topWall
    local leftWall = display.newRect(sceneGroup, 0, 0, 20, _S.actualHeight)
      leftWall.anchorX = 0; leftWall.x = _S.left - leftWall.width
      leftWall.anchorY = 0; leftWall.y = _S.top
      leftWall:setFillColor(0)
      leftWall.myName = "wall"
      physics.addBody( leftWall, "static", {friction=0, bounce = 1} )

    local rightWall = display.newRect(sceneGroup, 0, 0, 20, _S.actualHeight)
      rightWall.anchorX = 1; rightWall.x = _S.right + rightWall.width
      rightWall.anchorY = 0; rightWall.y = _S.top
      rightWall:setFillColor(0)
      rightWall.myName = "wall"
      physics.addBody( rightWall, "static", {friction=0, bounce = 1} )

    local topWall = display.newRect(sceneGroup, 0, 0, _S.actualWidth, 20)
      topWall.x = _S.centerX
      topWall.anchorY = 0; topWall.y = _S.top - 20
      topWall:setFillColor(0)
      topWall.myName = "wall"
      physics.addBody( topWall, "static", {friction=0, bounce = 1} )

    -- The bounce bar is the object where the ball bounces off
    bounceBar = display.newImageRect(sceneGroup, "images/bar.png", 225, 42)
      bounceBar.x = _S.centerX
      bounceBar.y = touchArea.y - (touchArea.height * 0.5)
      physics.addBody( bounceBar, "static", {friction=0, bounce = 1} )
      bounceBar.gravityScale = 0
      bounceBar.myName = "bar"

    -- A button to send the player back to the menu, only available on game over
    btn_menu = widget.newButton( {
        label = "Voltar ao Menu",
        fontSize = 52,
        font = "ChunkFive",
        width = 460,
        height = 140,
        labelColor = { default={ 28/255, 197/255, 160/255 }, over={ 0, 0, 0, 0.5 } },
        defaultFile = "images/button.png",
        overFile = "images/button.png",
        onEvent = onMenuTouch
      }
    )
    btn_menu.x = _S.centerX
    btn_menu.y = _S.centerY * 1.5
    btn_menu.alpha = 0
    sceneGroup:insert(btn_menu)

    -- touch listener function
    function touchArea:touch( event )
      if event.phase == "began" then
        display.getCurrentStage():setFocus( self, event.id ) -- first we set the focus on the object
        self.isFocus = true
        bounceBar.markX = bounceBar.x -- then we store the original x and y position

      elseif self.isFocus then

        if event.phase == "moved" then
          if(event.x > 0 and event.x < _S.right) then
            bounceBar.x = event.x - event.xStart + bounceBar.markX -- then drag our object
          end
        elseif event.phase == "ended" or event.phase == "cancelled" then
          -- we end the movement by removing the focus from the object
          display.getCurrentStage():setFocus( self, nil )
          self.isFocus = false
        end
      end
      return true -- return true so Corona knows that the touch event was handled properly
    end



end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
      circleTable[circleCounter] = createCircle()
      sceneGroup:insert(circleTable[circleCounter])

      tmr_createCircles = timer.performWithDelay(4000, function()
          circleCounter = circleCounter + 1
          circleTable[circleCounter] = createCircle()
          sceneGroup:insert(circleTable[circleCounter])
        end, 3)

      Runtime:addEventListener( "collision", onGlobalCollision )

      -- finally, add an event listener to our touchArea to allow it to be dragged
      touchArea:addEventListener( "touch", touchArea )

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
