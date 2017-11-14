local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- O código fora das funções do evento de cena abaixo só será executado uma vez a menos que
-- a cena é removida inteiramente (não reciclado) via "composer.removeScene ()"
-- -----------------------------------------------------------------------------------
 
 
 
 
-- -----------------------------------------------------------------------------------
-- Funções de evento de cena
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- O código aqui é executado quando a cena é criada pela primeira vez, mas ainda não apareceu na tela
    local background = display.newImageRect(sceneGroup, "images/background.png", _S.actualWidth, _S.actualHeight)
      background.x = _S.centerX; background.y = _S.centerY

    local txt_touchInstructions = display.newText(sceneGroup, "", 0, 0, "ChunkFive", 72)
      txt_touchInstructions.x = _S.centerX
      txt_touchInstructions.y = _S.centerY * 0.5

    local function onPlayTouch( event )     
      if ( "ended" == event.phase ) then
        composer.gotoScene("scene-game", "flip")
      end
    end
     
    local btn_play = widget.newButton( {        
        label = "Vamos jogar",
        fontSize = 52,
        font = "ChunkFive",
        width = 460,
        height =140,
        labelColor = { default={ 28/255, 197/255, 160/255 }, over={ 0, 0, 0.5, 0.2 } },
        defaultFile = "images/button.png",
        overFile = "images/button.png",
        onEvent = onPlayTouch
      }
    )
    btn_play.x = _S.centerX
    btn_play.y = _S.centerY * 1.5

    sceneGroup:insert(btn_play)

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- O código aqui é executado quando a cena ainda está fora da tela (mas está prestes a aparecer na tela)
 
    elseif ( phase == "did" ) then
      -- O código aqui é executado quando a cena está inteiramente na tela
      local prevScene = composer.getSceneName( "previous" )
      if(prevScene) then 
        composer.removeScene(prevScene)
      end 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- O código aqui é executado quando a cena está na tela (mas está prestes a sair da tela)
 
    elseif ( phase == "did" ) then
        -- O código aqui é executado imediatamente após a cena sair inteiramente da tela
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- O código aqui é executado antes da remoção da visão da cena
 
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
