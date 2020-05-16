local gl2d = {}

    function gl2d.new(display)
        return setmetatable({["display"] = display}, gl2d)
    end

    function lineToFunction(x1, y1, x2, y2)
        local m = math.sqrt(math.pow((x1 - x2), 2) +math.pow((y1 - y2), 2))
        local b = y1 - (m * x1)

        return function(x)
            return (m * x) + b
        end
    end

    function gl2d.drawLine(self, x1, y1, x2, y2)
        local g = rawget(self, "display")
        local fx = lineToFunction(x1, y1, x2, y2)
        local sx = math.min(x1, x2)
        local mx = math.max(x1, x2)
        for x=sx, mx, 1 do
            local y = fx(x)
            y = y - (y % 1)
            g.set(x, y, "x")
        end
    end

    function triangleArea(x1, y1, x2, y2, x3, y3)
        return math.abs((x1*(y2-y3) + x2*(y3-y1)+ x3*(y1-y2))/2.0)
    end

    function isInside(x, y, x1, y1, x2, y2, x3, y3)
        local area = triangleArea
        --[[
            double A = area (x1, y1, x2, y2, x3, y3); 
       /* Calculate area of triangle PBC */  
        double A1 = area (x, y, x2, y2, x3, y3); 
       /* Calculate area of triangle PAC */  
        double A2 = area (x1, y1, x, y, x3, y3); 
       /* Calculate area of triangle PAB */   
        double A3 = area (x1, y1, x2, y2, x, y); 
       /* Check if sum of A1, A2 and A3 is same as A */
        return (A == A1 + A2 + A3); 
        ]]

        local a = area (x1, y1, x2, y2, x3, y3)
        local a1 = area (x, y, x2, y2, x3, y3)
        local a2 = area (x1, y1, x, y, x3, y3)
        local a3 = area (x1, y1, x2, y2, x, y)
        return (A == (A1 + A2 + A3))
    end

    function gl2d.drawTriangle(self, x1, y1, x2, y2, x3, y3)
        local g = rawget(self, "display")
        local sx = math.min(x1, math.min(x2, x3))
        local sy = math.min(y1, math.min(y2, y3))
        local mx = math.max(x1, math.max(x2, x3))
        local my = math.max(y1, math.max(y2, y3))

        for x = sx, mx do
            for y = sy, my do
                if isInside(x, y, x1, y1, x2, y2, x3, y3) then
                    g.set(x, y, "x")
                end
            end
        end
    end

return gl2d