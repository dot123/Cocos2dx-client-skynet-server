local socketManager = require("app.scenes.socketManager")
local MainLayer = class("MainLayer", function()
    return display.newNode("MainLayer")
end)

function MainLayer:ctor()
    local bg = display.newSprite("image/default@2x.jpg")
    bg:setPosition(cc.p(display.cx ,display.cy))
    self:addChild(bg)

    socketManager.registerAllProtocol()
    socketManager:initSocket() 

    cc.ui.UIPushButton.new({ normal = "button/button_1020@2x.png", pressed = "button/button_1019@2x.png"})
    :onButtonClicked(function()
      socketManager:createUser()
    end)
    :pos(display.cx, display.cy)
    :addTo(self)
end

return MainLayer