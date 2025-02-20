name = "Rotator"
description="Rotatings thing obvs"

importLib("renderthreeD")

function subtract_matrix(m1,m2)
    local output = {}
    for n = 1,3 do
        output[n] = subtract_vectors(m1[n], m2[n])
    end
    return output
end

function getRotationMatrix(angle,axis)
    if axis == "x" then
        local xRotationMatrix = {
            xRot = { x = 1, y =0,z=0},
            yRot = {x=0, y=math.cos(angle),z=math.sin(angle)},
            zRot = {x=0, y= math.sin(angle)*-1,z=math.cos(angle)}
        }
        return xRotationMatrix
    end

    if axis == "y" then
        local yRotationMatrix = {
            xRot = { x = math.cos(angle), y =0,z=math.sin(angle)*-1},
            yRot = {x=0, y=1,z=0},
            zRot = {x=math.sin(angle), y= 0,z=math.cos(angle)}
        }
        return yRotationMatrix
    end

    if axis == "z" then
        local zRotationMatrix = {
            xRot = { x = math.cos(angle), y =math.sin(angle),z=0},
            yRot = {x=math.sin(angle)*-1, y=math.cos(angle),z=0},
            zRot = {x=0, y= 0,z=1}
        }
        return zRotationMatrix
    end

end

function multiplyMatrixByNumber (matrix,number)
    local output = {}
    for n = 1,3 do
        output[n] = timesVectorAndANumber(matrix[n],number)
    end
    return output
end

function easeTransformation (startMatrix,endPoint,progress) -- progrees from 0-1
    local difference = subtract_matrix(endPoint,startMatrix)
    local output = add_vectors(startMatrix,multiplyMatrixByNumber(difference,progress))
    return output
end





function add_vectors(v1,v2)
    local x = v1.x + v2.x
    local y = v1.y + v2.y
    local z = v1.z + v2.z
    return {x=x,y=y,z=z}
end

function timesVectorAndANumber(vec,num)
    return {x=vec.x*num,y= vec.y*num,z= vec.z*num}
end

function matrixMultiplication (matrix,vector) 
    print(vector.x==nil)
    local x = timesVectorAndANumber(matrix.xRot,vector.x)
    local y = timesVectorAndANumber(matrix.yRot,vector.y)
    local z = timesVectorAndANumber(matrix.zRot,vector.z)
    local out = add_vectors(x,y)
    out = add_vectors(out,z)
    return out
end

function notateArea()

    local minRange = -10
    local maxRange = 10

    local blocks = {}

    for x = minRange, maxRange do
        for y = minRange, maxRange do
            for z = minRange, maxRange do
                local block = dimension.getBlock(x,y,z).name 
                if block == "red_concrete" or block == "blue_concrete" or block == "green_concrete" or block == "air" then else
                    table.insert(blocks,{x=x+0.5,y=y+0.5,z=z+0.5,block=block})
                    client.execute("execute setblock " .. x .. " " .. y  .. " " .. z .. " " .. " air")
                end 
            end
        end
    end

    

    return blocks
end

registerCommand("transformArea", function (arguments)
    local intellisenseHelper = MakeIntellisenseHelper(arguments)
    local parser = intellisenseHelper:addOverload()
    
    axis = parser:matchString("axis")
    if axis == nil then
        print("§cAxis number is required!")
        return
    end

    local angle = parser:matchFloat("angle")
    if angle == nil then
        print("§cAngle number is required!")
        return
    end
    
    blocks = notateArea()


    
end, 
function (intellisense)
    local overload = intellisense:addOverload()
    overload:matchString("axis")
    overload:matchFloat("angle")
end, "spinny spinny things not just riht angles (ik)")


lastRanRotator = os.clock()
degreesThroguhRotator = 0


function render3d()
    if blocks == nil then return end
    gfx.color(255,0,0)
    for n = 1, #blocks do
        cubexyz(blocks[n].x,blocks[n].y,blocks[n].z,0.2,0.2,0.2)    
    end
    
    if lastRanRotator+  0.04 < os.clock() then
        lastRanRotator = os.clock()
        degreesThroguhRotator = degreesThroguhRotator + 0.1

        if degreesThroguhRotator > 1 then
            finished = true
            lastRanRotator = 10000000000000000000000000000000000000000*10^10000
            
        end
        


        newPoints={}
        for n = 1, #blocks do 
            local matrix = getRotationMatrix(90,"y")
            local newPoint = matrixMultiplication(matrix,blocks[n])
            table.insert(newPoints, {x=newPoint.x,y=newPoint.y,z=newPoint.z,block=blocks[n].block})
        end
        
    end
    gfx.color(0,255,0)
    for n = 1, #newPoints do
        if newPoints[n] == nil then else
            if finished then
                client.execute("execute setblock " .. newPoints[n].x .. " " .. newPoints[n].y .. " " .. newPoints[n].z .. " " .. newPoints[n].block)
            else
                cubexyz(newPoints[n].x,newPoints[n].y,newPoints[n].z,0.2,0.2,0.2)
            end
        end
    end
end











registerCommand("testMatrix multiply", function (arguments)
    local intellisenseHelper = MakeIntellisenseHelper(arguments)
    local parser = intellisenseHelper:addOverload()
    local test = parser:matchInt("test")
    if test == nil then
        print("§cTest number is required!")
        return
    end


    -- for x = 0,10 do
    --     for y = 0,10 do
    --         for z = 0,10 do
    --             local point = {x=x,y=y,z=z}
    --             local rotatedPoint = rotatePoint(angle,axis,point)
    --             client.execute("execute setblock " ..x .. " " .. y .. " " .. z .. " air")
    --             if dimension.getBlock(x,y,z).name == "air" then else
    --                 client.execute("execute setblock " .. rotatedPoint.x .. " " .. rotatedPoint.y .. " " .. rotatedPoint.z .. " dirt")
    --             end 
                
    --         end
    --     end
    -- end

    if test == 1 then
        local matrix = {
            xRot = {x= 1, y= 2, z= 9},
            yRot = {x = 3,y=5,z=7},
            zRot = {x=6,y=4,z=8}
        }
        vector = {x=68,y=72,z=130}

        out = matrixMultiplication(matrix,vector)
        print("x" .. out.x .. " y " .. out.y .. " z " .. out.z)
        assert(out.x == 14 and out.y == 14 and out.z == 14)
    end
    
end, 
function (intellisense)
    local overload = intellisense:addOverload()
    overload:matchInt("test")
end, "tests things")



