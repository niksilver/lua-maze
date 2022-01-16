-- Generate a maze of a given size.

-- This is our maze - an array of arrays.
-- maze[x][y] is row x, column y, holding a boolean value saying
-- if it's traversable.
-- The edge of maze is the border, so entirely false apart from entry/exit
-- points.
-- For a maze of size n, x and y run from 1 to 2*n+1

maze = {}
size = 8
width = 2*size + 1
height = 2*size + 1

-- Initialise the maze. At first, nothing will be traversable, but we will
-- put in the entry and exit points.
--
function init()
    for i = 1, height do
        maze[i] = {}
        for j = 1, width do
            maze[i][j] = false
        end
    end

    -- Cut the entry and exit points

    maze[2][1] = true
    maze[2][2] = true
    maze[height-1][width] = true
end

-- Cut paths throughout the whole maze.
--
function cut_paths()
    for i = 2, height, 2 do
        for j = 2, width, 2 do
            cut_path(i, j)
        end
    end
end

-- Cut a single random path from a traversable point, going as far
-- as it can without connecting to anything new.
--
function cut_path(y, x)
    -- Don't cut here if there's no path here already

    if maze[y][x] == false then
        return
    end

    -- Okay, let's extend what we can

    local delta_y, delta_x = get_deltas(y, x)
    if delta_x == nil then
        return
    end

    local next_x = x + 2 * delta_x
    local next_y = y + 2 * delta_y

    repeat
        maze[y + delta_y][x + delta_x] = true
        maze[next_y][next_x] = true
        x, y = next_x, next_y

        delta_y, delta_x = get_deltas(y, x)
        if delta_x == nil then
            return
        else
            next_x = x + 2 * delta_x
            next_y = y + 2 * delta_y
        end

    until delta_x == nil
end

-- Can we cut to a particular location? True if the location is both on
-- the maze and hasn't yet been cut into.
--
function can_cut(y, x)
    return x >= 1 and x <= width and y >= 1 and y <= height and maze[y][x] == false
end

-- Randomly work out which direction we're going in from a given y,x location.
-- Will find some direction if at all possible.
--
-- Returns two values, one for the y change and one for the x change
-- (values are +1, 0, or -1), but will return nil,nil if no direction
-- is possible
--
function get_deltas(y, x)
    local directions = {
        { 1, 0 },
        { 0, 1 },
        { -1, 0 },
        { 0, -1 }
    }

    -- Randomise the possible directions

    for i = 1, 3 do
        local i2 = math.random(4)
        directions[i], directions[i2] = directions[i2], directions[i]
    end

    -- Find the first possible direction

    for i = 1, 4 do
        local delta_y, delta_x = table.unpack(directions[i])
        if can_cut(y + 2*delta_y, x + 2*delta_x) then
            return delta_y, delta_x
        end
    end

    -- No direction found

    return nil, nil
end

-- Print out the maze.
--
function print_maze()
    for i = 1, height do
        for j = 1, width do
            if maze[i][j] == true then
                io.write("  ")
            else
                io.write(barrier_string(i, j))
            end
        end
        io.write("\n")
    end
end

-- Get a location value safely. Out-of-bounds indices are okay.
--
function safe_get(y, x)
    if y < 1 or y > height or x < 1 or x > width then
        return true
    else
        return maze[y][x]
    end
end

-- The string to print for a barrier in the maze.
--
function barrier_string(y, x)
    -- Possible maze values above, right, below, left... and their strings

    local str = {
        ["    "] = "**",
        ["   *"] = "-+",
        ["  * "] = "++",
        ["  **"] = "-+",
        [" *  "] = "+-",
        [" * *"] = "--",
        [" ** "] = "+-",
        [" ***"] = "++",

        ["*   "] = "++",
        ["*  *"] = "-+",
        ["* * "] = "||",
        ["* **"] = "+|",
        ["**  "] = "+-",
        ["** *"] = "++",
        ["*** "] = "|+",
        ["****"] = "++"
    }
    local convert = {
        [true] = " ",
        [false] = "*"
    }

    local a = safe_get(y-1,x)
    local b = safe_get(y,x+1)
    local c = safe_get(y+1,x)
    local d = safe_get(y,x-1)

    a, b, c, d = convert[a], convert[b], convert[c], convert[d]

    return str[ a..b..c..d ]
end

-- Generate the maze

math.randomseed( os.time() )
init()
cut_paths()
print_maze()
