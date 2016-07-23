local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
  	local layer = require("app.scenes.MainLayer"):new()
    self:addChild(layer)
end

return MainScene