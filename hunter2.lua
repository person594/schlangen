function init()
  global_x = 0
  global_y = 0
  global_direction = 0
  seen_segments = {}
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

function distance(dx, dy)
    return math.sqrt(dx^2 + dy^2)
end

function update_reference_frame(speed, d_angle)
    global_direction = (global_direction + d_angle) % (2*math.pi)
    global_x = global_x + math.sin(global_direction) * speed
    global_y = global_y + math.cos(global_direction) * speed
    
end

function world_coordinates(distance, direction)
    world_direction = direction + global_direction
    world_x = global_x + distance*math.sin(direction)
    world_y = global_y + distance*math.cos(direction)
    return world_x, world_y
end

function local_coordinates(x, y)
    distance = math.sqrt((x - global_x)^2 + (y - global_y)^2)
    angle = math.atan2(x - global_x, y - global_y)
    return distance, angle
end

function find_new_segments()
    epsilon = 100
    --local segments = findSegments(self.sight_radius, false)
    local segments = findFood(self.sight_radius, 0)
    for i, new in pairs(segments) do
        local new_x, new_y = world_coordinates(new.dist, new.d)
        for j, seen in pairs(seen_segments) do
            seen_x, seen_y = world_coordinates(seen.dist, seen.d)
            local dist = distance(new_x - seen_x, new_y - seen_y)
            if dist < epsilon then
                log(string.format("(%f): %f", new.v - seen.v, dist))
            end
        end
    end
    seen_segments = segments
end



function step()
    find_new_segments()
    local dir = self.max_step_angle * (2* math.random() - 1)
    update_reference_frame(10, dir)
    return dir
end
