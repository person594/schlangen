--- WELCOME TO YOUR FIRST SNAKE!
-- It is programmed in the Lua language. If you didn't used 
-- it until now, ask us or visit https://www.lua.org/manual/5.3/.
-- 
-- You can edit this code, save and run it.
-- You should see log output at the bottom of this page,
-- and a live view on your snake's wellbeing on the right

--- init() is called once upon creation of the bot
-- initialize your data here, and maybe set colors for your snake
function init()
    self.colors = { 0xFF0000, 0x808080 }
end

function clamp(x, lower, upper)
    if x < lower then return lower end
    if x > upper then return upper end
    return x
end

function will_collide(segment, new_angle)
    segment_angle = segment.d - new_angle
    if math.abs(segment_angle) >= math.pi/2 then
        return false
    end
    buffer = self.segment_radius
    min_distance = segment.r + self.segment_radius + buffer
    pass_distance = math.sin(segment_angle)
    if pass_distance <= min_distance then
        return true
    else
        return false
    end
end

function panic_distance(margin_size)
    return math.log(margin_size)/math.log(self.max_step_angle)
end

--- step() is called once every frame, maybe up to 60 times per second.
-- implement your game logic here.
-- after deciding what your bot should do next,
-- just return the desired steering angle.
-- a negative angle means turn left and a positive angle means turn right.
-- with 0, the snake keeps its current direction.
function step()
    -- there is some info in the "self" object, e.g. your current head/segment radius
    local own_radius = self.r

    -- your snake needs food to grow
    -- to find food in your head's surroundings, call something like that:
    local food = findFood(100, 0.8)
    -- this will give you all food in maximum distance of 100 around your head,
    -- with a mass of at least 0.8

    -- you can iterate over the result:
    local best_food = nil
    local best_rating = 0
    local new_angle = 0
    for i, item in food:pairs() do

        -- distance of the food item, relative to the center of your head
        local distance = item.dist

        -- direction to the food item, in radiens (0..2*math.pi)
        -- 0 means "straight ahead", math.pi means "right behind you"
        local direction = item.d

        -- mass of the food item. you will grow this amount if you eat it.
        -- realistic values are 0 - 4
        local rating = item.v / item.dist
        if rating > best_rating then
            best_rating = rating
            best_food = item
            new_angle = clamp(best_food.d, -self.max_step_angle, self.max_step_angle)
        end
	end

    local panic = false
    

    -- you should also look out for your enemies.
    -- to find snake segments around you, call:
    local segments = findSegments(100, false)
    
    local p_distance = math.max(30, panic_distance(3*self.segment_radius))

    -- in return, you get a list of
    -- all snake segments nearer than 100 to your head,
    -- in this case not including your own segments:
    for i, item in segments:pairs() do

        -- id of the bot the segment belongs to
        -- (you can compare this to self.id)
        local bot = item.bot

        -- distance to the center of the segment
        local distance = item.dist - item.r - self.segment_radius

        -- direction to the segment, in radiens (0..2*math.pi)
        local direction = item.d

        -- radius of the segment
        local radius = item.r
        local margin_size = 2*(radius + self.segment_radius)
        if distance <= p_distance and will_collide(item, new_angle) then
            panic = true
        end
	end
    if panic then
        log("panic!")
        return self.max_step_angle
    end
    if best_food ~= nil then
        return new_angle
    else
        return 0
    end
end
