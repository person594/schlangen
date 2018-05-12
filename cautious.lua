function init()
    self.colors = { 0xFF0000, 0x808080 }
end

local resolution = 32

function bucket_to_dir(bucket)
    return ((bucket-1) / (resolution-1) - 0.5) * 2*math.pi
end

function dir_to_bucket(dir)
    while (dir < -math.pi) do
        dir = dir + 2*math.pi
    end
    while (dir > math.pi) do
        dir = dir - 2*math.pi
    end
    b = math.floor( ((dir / (2*math.pi)) + 0.5) * (resolution-1) + 1)
    if b > resolution then
        return resolution
    else
        return b
    end
end

function scan_segments(radius)
    local directions = {}
    local segments = findSegments (radius, false)
    local enemy_speed = 1
    for i, segment in pairs(segments) do
        local center = segment.d
        local distance = segment.dist - segment.r
        local spread = math.atan(enemy_speed + (segment.r + self.segment_radius / distance))
        local left = center - spread/2
        local right = center + spread/2
        for b=dir_to_bucket(left)-1, dir_to_bucket(right)+1 do
            if directions[b] == nil then
                directions[b] = distance
            else
                directions[b] = math.min(directions[b], distance)
            end
        end
    end
    return directions
end

function food_dir(radius)
    local turning_radius = 1 / self.max_step_angle
    local best_value = 0
    local best_dir = (math.random() - 0.5) * math.pi / 8
    local foods = findFood(radius, 5)
    for i, food in pairs(foods) do
        local turn_point_dist = (food.dist - turning_radius)
        local turn_point_penalty = 1 / (turn_point_dist * turn_point_dist + 0.0001)
        local fake_dist = food.dist + ((math.sin(food.d)^4) * turn_point_penalty)
        local v = food.v / fake_dist
        if v > best_value then
            best_value = v
            best_dir = food.d
        end
    end
    return best_dir
end

function is_safe(dir, buckets)
    return buckets[dir_to_bucket(dir)] == nil
end

function safest_dir(buckets)
    local farthest_bucket = 1
    local farthest_dist = 0
    for i=1, resolution do
        local b = math.floor(resolution / 2)
        if i % 2 == 0 then
            b = b - math.ceil(i / 2)
        else
            b = b + math.floor(i / 2)
        end
        if buckets[b] == nil then
            return bucket_to_dir(b)
        elseif buckets[b] > farthest_dist then
            farthest_dist = buckets[b]
            farthest_bucket = b
        end
    end
    return bucket_to_dir(farthest_bucket)
end

function step()
    local dir = food_dir(100)
    local buckets = scan_segments(1000)
    if not is_safe(dir, buckets) then
        log("panic")
        dir = safest_dir(buckets)
        log(dir)
    end
    return dir
end


