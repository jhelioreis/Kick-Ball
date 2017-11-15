local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- O código fora das funções do evento de cena abaixo só será executado uma vez a menos que
-- a cena é removida inteiramente (não reciclado) via "composer.removeScene ()"
local physics = require( "physics" )
physics.start()
--physics.setDrawMode ("híbrido") - habilite isso para ver os limites da física
physics.setGravity( 0, 19.6 )

local createCircle -- Esta é uma função para manter todos os círculos criados
local circleTable = {} -- Esta é uma tabela que contém todos os objetos do círculo
local circleCounter = 1 -- acompanhar o número de círculos no palco
local tmr_createCircles -- uma variável para acompanhar o cronômetro

local touchArea, background

local onGlobalCollision, gameOver
local btn_menu, onMenuTouch
local txt_gameOver, txt_playerScore
local scoreCounter = 0 -- acompanhar o número de saltos bem sucedidos
local bounceBar -- a variável para manter o objeto da barra de rejeição
local isGameOver = false -- permite saber se o jogo acabou ou não
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Funções de evento de cena

-- gameOver será chamado quando o jogo acabar. Pare a física, remova objetos e mostre o jogo
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

createCircle = function()

  transition.to(background, {xScale=1.15, yScale=1.15, time=300})
  transition.to(background, {xScale=1, yScale=1, delay=300})

  local circle = display.newImageRect("images/Ball.png", 125, 125)
    circle.x = 450; circle.y = 100
    circle.alpha = 0
    circle.myName = "Ball"
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

-- Isso é chamado quando dois objetos de física colidem uns com os outros.
onGlobalCollision = function(event)
    local obj1 = event.object1
    local obj2 = event.object2

    if ( event.phase == "ended" ) then
      if( obj1.myName == "bar" and obj2.myName == "Ball" and isGameOver == false) then

        timer.performWithDelay(1, function()
          if(isGameOver == false) then
            obj2:applyLinearImpulse( math.random(-30,30), math.random(-30,-10), obj1.x, obj1.y)
          end
        end, 1)

        local rotateTo = obj2.rotation + math.random(-50,50)
        transition.to(obj2, {rotation=rotateTo} )

        addToScore()
      end

      if(obj1.myName == "touchArea" and obj2.myName == "Ball") then
        gameOver()
      end
      if(obj1.myName == "Ball" and obj2.myName == "touchArea") then
        gameOver()
      end
    end
end

-- Finalmente, envie o jogador de volta ao menu
onMenuTouch = function(event)
  if ( "ended" == event.phase ) then
    composer.gotoScene("scene-menu", "fade")
  end
end

function scene:create( event )

    local sceneGroup = self.view

    -- Exibir um plano de fundo
    background = display.newImageRect(sceneGroup, "images/background1.png", _S.actualWidth, _S.actualHeight)
      background.x = _S.centerX; background.y = _S.centerY

    -- Crie a área de toque que irá responder ao arrasto do jogador e irá ligar para o jogo se uma bola entrar em colisão com a área de toque
    touchArea = display.newRect(sceneGroup, 0, 0, _S.actualWidth, 200)
      touchArea.x = _S.centerX
      touchArea.y = _S.bottom - (touchArea.height * 0.5)
      touchArea:setFillColor(0,0,0,0.25)
      touchArea.myName = "touchArea"
      physics.addBody( touchArea )
      touchArea.gravityScale = 0
      touchArea.isSensor = true

    -- Objetos de texto para instruções: txt_touchInstructions, txt_playerScore, txt_gameOver
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

    -- Crie os limites: leftWall, rightWall, topWall
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

    --A barra de rejeição é o objeto onde a bola salta
    bounceBar = display.newImageRect(sceneGroup, "images/barra.png", 225, 42)
      bounceBar.x = _S.centerX
      bounceBar.y = touchArea.y - (touchArea.height * 0.5)
      physics.addBody( bounceBar, "static", {friction=0, bounce = 1} )
      bounceBar.gravityScale = 0
      bounceBar.myName = "barra"

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

    function touchArea:touch( event )
      if event.phase == "began" then
        display.getCurrentStage():setFocus( self, event.id ) -- primeiro focamos o objeto
        self.isFocus = true
        bounceBar.markX = bounceBar.x -- então nós armazenamos a posição x e y original

      elseif self.isFocus then

        if event.phase == "moved" then
          if(event.x > 0 and event.x < _S.right) then
            bounceBar.x = event.x - event.xStart + bounceBar.markX -- então arraste o objeto
          end
        elseif event.phase == "ended" or event.phase == "cancelled" then
          -- acabamos com o movimento removendo o foco do objeto
          display.getCurrentStage():setFocus( self, nil )
          self.isFocus = false
        end
      end
      return true -- volte  para que Corona saiba que o evento de toque foi tratado corretamente
    end



end


-- exposição()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- O código aqui é executado quando a cena ainda está fora da tela (mas está prestes a aparecer na tela)

    elseif ( phase == "did" ) then
        -- O código aqui é executado quando a cena está inteiramente na tela
      circleTable[circleCounter] = createCircle()
      sceneGroup:insert(circleTable[circleCounter])

      tmr_createCircles = timer.performWithDelay(4000, function()
          circleCounter = circleCounter + 1
          circleTable[circleCounter] = createCircle()
          sceneGroup:insert(circleTable[circleCounter])
        end, 3)

      Runtime:addEventListener( "collision", onGlobalCollision )

      -- finalmente, adicione um ouvinte de eventos ao nosso touchArea para permitir que ele seja arrastado
      touchArea:addEventListener( "touch", touchArea )

    end
end


-- ocultar()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- O código aqui é executado quando a cena está na tela (mas está prestes a sair da tela)

    elseif ( phase == "did" ) then
        -- O código aqui é executado imediatamente após a cena sair inteiramente da tela

    end
end


-- destruir()
function scene:destroy( event )

    local sceneGroup = self.view
    -- O código aqui é executado antes da remoção da visão da cena

end


-- -----------------------------------------------------------------------------------
-- Função de evento de cena ouvintes
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
