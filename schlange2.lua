function init()
    self.colors = { 0xFF0000, 0xFF8080, 0xFFFF00, 0x00FF00, 0x0000FF, 0x8000FF }
end

function evade_dir()
    local threshhold = 5
    local sum_urgency = 0
    local direction = nil
    for i, segment in pairs(findSegments (self.sight_radius, false)) do
        if math.abs(segment.d) < 2*math.pi / 3 then
            local side = segment.d / math.abs(segment.d)
            local urgency = math.cos(segment.d / 2) / (segment.dist / self.sight_radius)^2
            sum_urgency = sum_urgency + urgency
            if direction == nil then
                direction = -side*urgency
            else
                direction = direction - side*urgency
            end
        end
    end
    if sum_urgency > threshhold then
        direction = self.max_step_angle * direction / math.abs(direction)
        log(direction)
        return direction
    else
        return nil
    end
    
end

function atan2(x, y)
    if y >= 0 then
        return math.atan(x/y)
    else
        if x < 0 then
            return math.atan(x/y) - math.pi
        else
            return -math.atan(x/y) + math.pi
        end
    end
end

function food_dir()
    local foods = findFood(self.sight_radius, 5)
    local centroid_x = 0
    local centroid_y = 0
    local centroid_mass = 0
    for i, food in pairs(foods) do
        local c = math.cos(food.d)
        local food_x = food.dist * math.sin(food.d)
        local food_y = food.dist * c
        local value = (c + 3) * food.v / food.dist^2
        centroid_x = centroid_x + food_x * value
        centroid_y = centroid_y + food_y * value
        centroid_mass = centroid_mass + value
    end
    if centroid_mass == 0 then return 0 end
    centroid_x = centroid_x / centroid_mass
    centroid_y = centroid_y / centroid_mass
    centroid_dir = atan2(centroid_x, centroid_y)
    local best_food = nil
    local best_deflection = nil
    for i, food in pairs(foods) do
        local angle_dif = math.abs(food.d - centroid_dir)
        local deflection = math.sin(angle_dif) * food.dist / food.v
        
        
        if best_deflection == nil then
            best_food = food
            best_deflection = deflection
        else
            if deflection < best_deflection then
                best_deflection = deflection
                best_food = food
            end
        end
    end
    return best_food.d
    -- local angle = math.atan2(centroid_x, centroid_y)
    -- return angle
end

function step()
    local evade_direction = evade_dir()
    if evade_direction ~= nil then
        return evade_direction
    else
        return food_dir()
    end
end
