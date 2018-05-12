function init()
    self.colors = { 0xFF0000, 0xFF8080, 0xFFFF00, 0x00FF00, 0x0000FF, 0x8000FF }
end


function evade_hunt_dir()
    local evade_threshhold = 2
    local hunt_threshhold = 3
    local boost_threshhold = 5
    local max_evade_urgency = 0
    local max_hunt_urgency = 0
    local sum_evade_dir = nil
    local sum_hunt_dir = nil
    for i, segment in pairs(findSegments (self.sight_radius, false)) do
        local side = segment.d / math.abs(segment.d)
        local edge_distance = segment.dist - segment.r
        local urgency = (edge_distance / self.sight_radius)^-2

        if math.abs(segment.d) <= math.pi / 3 then -- evade
            max_evade_urgency = math.max(max_evade_urgency, urgency)
            if sum_evade_dir == nil then
                sum_evade_dir = -side*urgency
            else
                sum_evade_dir = sum_evade_dir - side*urgency
            end
        elseif math.abs(segment.d) < 2*math.pi / 3 then -- hunt
            max_hunt_urgency = math.max(max_hunt_urgency, urgency)
            if math.abs(segment.d) > 3*math.pi / 5 then -- too far behind us, turn towards it
                if sum_hunt_dir == nil then
                    sum_hunt_dir = side * urgency
                else
                    sum_hunt_dir = sum_hunt_dir + side * urgency
                end
            else -- too far ahead -- turn away
                if sum_hunt_dir == nil then
                    sum_hunt_dir = -side * urgency
                else
                    sum_hunt_dir = sum_hunt_dir - side * urgency
                end
            end
            
        end
    end
    if max_evade_urgency > evade_threshhold then
        if last_move ~= "evade" then
            last_move = "evade"
            log("evade")
        end
        return sum_evade_dir / math.abs(sum_evade_dir) * self.max_step_angle
    elseif max_hunt_urgency > hunt_threshhold then
        if last_move ~= "hunt" then
            last_move = "hunt"
            log("hunt")
        end
        return sum_hunt_dir / math.abs(sum_hunt_dir) * self.max_step_angle, max_hunt_urgency > boost_threshhold
    else
        if last_move ~= "eat" then
            last_move = "eat"
            log("eat")
        end
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
    local foods = findFood(self.sight_radius, 0)
    local centroid_x = 0
    local centroid_y = 0
    local centroid_mass = 0
    for i, food in pairs(foods) do
        local c = math.cos(food.d)
        local food_x = food.dist * math.sin(food.d)
        local food_y = food.dist * c
        local value = (c + 5) * food.v / food.dist^2
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
    local evade_hunt_direction, boost = evade_hunt_dir()
    if evade_hunt_direction ~= nil then
        return evade_hunt_direction, boost
    else
        return food_dir()
    end
end
