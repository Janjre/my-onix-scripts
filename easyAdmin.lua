name= "Easy commands"
description= "Lets you easily run commands to do fun things"

importLib("onDemandRendering.lua")

entitySelectionItem = "mace"
selectRadius = 5

--keybinds for cycles through list of commands
upThroughCommands = client.settings.addNamelessKeybind("up",21)
downThroughCommands = client.settings.addNamelessKeybind("down",22)

function saveSettings()
    io.open("commands.json", "w"):write(tableToJson(settings)):close()
end

function loadSettings()
    local file = io.open("commands.json", "r")
    
    if file == nil then print("§cNo settings saved!") return end
    settings =  jsonToTable(file:read("a"))
end

client.settings.addFunction("Save settings","saveSettings","Save")
client.settings.addFunction("Load settings","loadSettings","Load")

client.settings.addCategory("Commands")

settings = {}

function unhidePossibility()
    for i, setting in ipairs(settings) do
        if setting.command.visible == false then
            setting.command.visible = true
            setting.keybind.visible = true
            break
        end
    end
end

function createPossibilities()
    for n = 1, 50 do
        local command = client.settings.addNamelessTextbox("Command (ran/entity)","")
        local keybind = client.settings.addNamelessKeybind("key",0 )
        command.visible = false
        keybind.visible = false

        table.insert(settings,{command=command,keybind=keybind})
    end
end

createButton = client.settings.addFunction("Create new command","unhidePossibility","Create")
client.settings.addAir(5)
createPossibilities()



client.settings.addAir(10)

function removeCommand()
    for i, setting in ipairs(settings) do
        if setting.keybind.value == deleteKey.value then
            -- print(deleteKey.value)
            -- print("==")
            -- print(setting.keybind.value)
            
            -- print(setting.command.value)
            setting.command.visible = false
            setting.keybind.visible = false
            -- print(type(setting.keybind))
            -- print(type(setting.command))    

            break
        end
    end
end

client.settings.addFunction("Remove by keybind","removeCommand","Remove")
deleteKey = client.settings.addNamelessKeybind("key",0)

client.settings.stopCategory()

function getLookingBlock(maxDist)
    for n = 2, maxDist do
        local xPos, yPos, zPos = player.forwardPosition(n)
        local block = dimension.getBlock(math.floor(xPos), math.floor(yPos), math.floor(zPos)).name 
        if block == "air" or block == "water" then else
            return xPos, yPos, zPos
        end
    end
end

function drawSelectionSphere(x, y, z, radius)
    for i = -radius, radius do
        for j = -radius, radius do
            for k = -radius, radius do
                if i^2 + j^2 + k^2 <= radius^2 then
                    local curCube = addCube(x+i, y+j, z+k, {r=255, g=0, b=0, a=0.01}, math.huge)
                    local exists = false
                    for n = 1, #cubesInSel do
                        cubez = cubesInSel[n]
                        if cubez.x == curCube.x and cubez.y == curCube.y and cubez.z == curCube.z then
                            exists = true
                            break
                        end
                    end
                    if exists then
                        -- print("§cremoved cube - cube already exists")
                        curCube:remove()
                    else
                        table.insert(cubesInSel, curCube)
                    end
                end
            end
        end
    end
end
cubesInSel = {}

event.listen("KeyboardInput",function (key,down)
    for i, setting in ipairs(settings) do
        if setting.keybind.visible == true then 
            if setting.keybind.value == key then
                if down then
                    client.execute("execute execute as @e[tag=selected] at @s run " .. setting.command.value)
                end
            end
        end
    end
    if down then
        if drawRenderQueue2d then
            if key == upThroughCommands.value then
                pointInList = pointInList - 1
                if pointInList < 1 then
                    pointInList = #renderQueue2d
                end
            end
            if key == downThroughCommands.value then
                pointInList = pointInList + 1
                if pointInList > #renderQueue2d then
                    pointInList = 1
                end
            end
        end
    end
end)

tickrate = 20

pointInList = 1

renderQueue2d = {}

event.listen("MouseInput", function(button, down)
    
    local selectedPos = player.selectedPos()
    local selectedItem = player.inventory().selectedItem()

    if gui.mouseGrabbed() then return end

    if selectedItem and selectedItem.name ==  entitySelectionItem  then
        if button == 1 then
            if player.selectedEntity() then
                local entity = player.selectedEntity()
                local x,y,z = entity.ppx, entity.ppy, entity.ppz
                -- print("execute execute positioned "..x .. " " .. y .. " " .. z .. " run tag @e[r=0.2] add selected")
                client.execute("execute execute positioned "..x .. " " .. y .. " " .. z .. " run tag @e[r=0.2] add selected")
                return true
            end
            if down then else
                for _, cubey in ipairs(cubesInSel) do
                    cubey:remove()
                end
                cubesInSel = {}
            end
            LMB = down
        elseif button == 2 then
            RMB = down
        end

        if button == 3 then
            
            if down then
                renderQueue2d = {}    
                for i, setting in ipairs(settings) do
                    if setting.keybind.visible == true then 
                        table.insert(renderQueue2d, setting.command.value)     
                    end
                end
                drawRenderQueue2d = true
            else
                drawRenderQueue2d = false
            end 
        end      
    
        if button == 2 then
            -- print("HIIIIIIIIIIIIIIIIIIIIIIIIIIIII")
            if down then 
                local commandToExecute = renderQueue2d[pointInList]
                -- print(tableToJson(renderQueue2d))
                if commandToExecute then
                    client.execute("execute execute as @e[tag=selected] at @s run " .. commandToExecute)
                    -- print("Button two pressed executing " .. commandToExecute)
                end
            end
        end
    end
    -- print("button: " .. button .. " down: " .. tostring(down))

    
    if player.inventory().selectedItem() then 
        
        if player.inventory().selectedItem().name == "clock" then
            if button == 1 and down then
                -- print("you clicked the clock " .. tickrate .. " tickrate == 20" .. tostring(tickrate == 20))
                if tickrate ~= 20 then
                    -- print("time was paused so it has been resumed")
                    client.execute("tickrate server 20")
                    tickrate = 20
                else
                    -- print("time was not paused so it has been paused")
                    client.execute("tickrate server 0")
                    tickrate = 0
                end
                
            
            end            

            if button == 4 then
                -- print("button 4 pressed")
                if not down then
                    tickrate = tickrate + 1
                else
                    tickrate = tickrate - 1
                end
                -- print("Tickrate set to " .. tickrate)
                client.execute("tickrate server " .. tickrate)
            end
        end
    end 
        
    
end)

function update ()
    if LMB and not RMB then
        local xPos, yPos, zPos = getLookingBlock(1000)
        if xPos then
            drawSelectionSphere(xPos, yPos, zPos, selectRadius)
            client.execute("execute execute positioned ".. xPos .. " " .. yPos .. " " .. zPos .. " run tag @e[r="..selectRadius.."] add selected")
            -- client.execute("execute execute positioned ".. xPos .. " " .. yPos .. " " .. zPos .. " run effect @e[r="..selectRadius.."] levitation 1 10")

        end
    end
    
    if RMB and LMB then client.execute("execute tag @e remove selected"); selectedEnties = 0 end
    
    client.execute("execute execute as @e[tag=selected] at @s run particle minecraft:basic_flame_particle ~ ~2 ~")



end

function render3d(dt)
    renderQueue(dt)
end

selectedEnties = 0

event.listen("ChatMessageAdded", function(message, username, type, xuid)
    -- local formattedMessage = message:gsub("§", "{section}")
    -- print(formattedMessage)
    if message == "§cNo targets matched selector" or
       message == "§cTarget either already has the tag or has too many tags" or 
       string.sub(message,1,27)=="§cFailed to execute 'tag' " or
       message == "Request to create minecraft:basic_flame_particle sent to all players."  
    then 
        return true
    end
    if string.sub(message,1,24) == "Added tag 'selected' to " then
        selectedEnties = selectedEnties + 1
        return true
    end
end)

function render(dt)
    
    gfx.text(0,0, "Selected entities ~=" .. selectedEnties)
    gfx.text(0,10, "Tickrate: " .. tickrate)
    gfx.text(0,20, "Select radius: " .. selectRadius)
    gfx.text(0,30, "poiint in list" .. pointInList)
    if drawRenderQueue2d then
        for i, j in ipairs(renderQueue2d) do
            

            if i == pointInList then
                gfx.color(255,0,0)
            end

            gfx.text(0,(10*i)+30, j)
            gfx.color(255,255,255)
        end
    end
    
    -- gfx.text(200,0,tableToJson(renderQueue2d))
end