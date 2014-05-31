
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self._label=ui.newTTFLabel({
            text ="",
            size = 18,
            color = ccc3(255, 255, 255),
            align = ui.TEXT_ALIGN_CENTER,
            valign =ui.TEXT_VALIGN_TOP,
            dimensions = CCSize(300, 350),
        })
        :pos(display.cx, display.bottom)
        :addTo(self)

     self._funlabel=ui.newTTFLabel({
            text =[[
function calcDegrees(target,origin,force)
    local degrees=math.atan2(target.x - origin.x, target.y - origin.y)

    if not force then
        return degrees
    end

    local yforce=force*math.cos(degrees)
    local xforce=force*math.sin(degrees)

    return degrees,xforce,yforce
end
]],
            size = 18,
            color = ccc3(128, 128, 128),
            align = ui.TEXT_ALIGN_LEFT,
            valign =ui.TEXT_VALIGN_TOP,
            dimensions = CCSize(display.width, display.height),
        })
        :pos(display.left, display.top)
        :addTo(self)
    self._funlabel:setAnchorPoint(ccp(0,1))


    self._info={}
    for i=1,3 do
        self._info[i]=ui.newTTFLabel({
                text ="",
                size = 15,
                color = ccc3(255, 255, 255),
                align = ui.TEXT_ALIGN_LEFT,
            })
            :pos(display.cx, display.bottom)
            :addTo(self,100)
        self._info[i]:setAnchorPoint(ccp(-0.2,1.2))
    end


    local layer = display.newLayer()
    layer:setTouchEnabled(true)
    layer:addTouchEventListener(handler(self, self.onTouch))
    self:addChild(layer)
 
    self._debugDraw=CCDrawNode:create()
    self:addChild(self._debugDraw,10)
    self.pause=true

    self.node=CCDrawNode:create()
    self:addChild(self.node,1000)

end

function MainScene:calcDegrees(target,origin,force)
    local degrees=math.atan2(target.x - origin.x, target.y - origin.y)

    if not force then
        return degrees
    end

    local yforce=force*math.cos(degrees)
    local xforce=force*math.sin(degrees)

    -- print("-----------",degrees,xforce,yforce)
    return degrees,xforce,yforce
end


function MainScene:onTouch(event, x, y)
    self.pause=true
    if self.handle then
        self:stopAction(self.handler)
        self.handle=nil
    end

    -- print(event, x, y)

    self._debugDraw:clear()
    local origin=ccp(display.cx,display.cy)
    local target=ccp(x,y)
    local distance=ccpDistance(origin,target)

    local degrees,xoffset,yoffset=self:calcDegrees(target,origin,distance)
    local angle=degrees/3.1415926*180

    if event == "began" then

    elseif event == "moved" then


    elseif event == "ended" then
        --print(event, x, y)
    end

    local tab={
        {ccp(origin.x,origin.y),ccp(target.x,origin.y),1,ccc4f(0,0,1,1),value=xoffset},
        {ccp(target.x,origin.y),ccp(target.x,target.y),1,ccc4f(0,1,0,1),value=yoffset},
        {origin,target,1,ccc4f(1,0,0,1),value=distance},
    }

    for i,v in ipairs(tab) do
        self._debugDraw:drawSegment(unpack(v))
        self._info[i]:setPosition((v[1].x+v[2].x)*0.5,(v[1].y+v[2].y)*0.5)
        self._info[i]:setString(math.ceil(v.value))
    end

    self._debugDraw:drawDot(origin,3,ccc4f(1,0,0,1))
    self._debugDraw:drawDot(target,3,ccc4f(1,0,0,1))
    self._debugDraw:drawDot(ccp(target.x,origin.y),3,ccc4f(1,0,0,1))


    self.yoffset=yoffset*0.01
    self.xoffset=xoffset*0.01




    local str=string.format([[
angle:%.2f
degrees:%.2f
]],angle,degrees)

    self._label:setString(str)


    self.handle=self:performWithDelay(function()
        self.pause=false
        self.node:setPosition(origin)
    end, 1)


    return true -- 返回 true 表示这个 CCNode 在触摸开始后接受后续的事件
end

function MainScene:update()
    self.node:clear()

    if self.pause then
        return
    end
    self.node:drawDot(ccp(0,0),5,ccc4f(1,1,1,1))

    self.node:setPosition(self.node:getPositionX()+self.xoffset,self.node:getPositionY()+self.yoffset)

end
function MainScene:onEnter()
    if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then app.exit() end
            end)
            self:addChild(layer)

            layer:setKeypadEnabled(true)
        end, 0.5)
    end
    self:schedule(handler(self,self.update), 1)
end

function MainScene:onExit()
end

return MainScene
