-- Generate a maze of a given size.

-- This is our maze - an array of arrays.
-- maze[x][y] is row x, column y, holding a boolean value saying
-- if it's traversable.
-- The edge of maze is the border, so entirely false apart from entry/exit
-- points.
-- For a maze of size n, x and y run from 1 to 2*n+1
--
maze = {}
size = 3
width = 2*size + 1
height = 2*size + 1

-- Initialise the maze. At first, nothing will be traversable, but we will
-- put in an entry poing. Later we'll cut some paths.
--
function init()
    for i = 1, height do
        maze[i] = {}
        for j = 1, width do
            maze[i][j] = false
        end
    end

    -- Cut an entry point

    maze[2][1] = true
    maze[2][2] = true
end

-- Create paths throughout the whole maze.
--
function create_paths()
    for i = 2, height, 2 do
        for j = 2, width, 2 do
            create_path(i, j)
        end
    end
end

-- Create a single random path from a traversable point, going as far
-- as it can without connecting to anything new.
--
function create_path(y, x)
    -- Don't cut here if there's no path here already

    print("Creating path from " .. y .. "," .. x)
    if maze[y][x] == false then
        print("  Can't create path")
        return
    end
    print("  Looking good")

    -- Okay, let's extend what we can

    delta_y, delta_x = get_deltas(y, x)
    if delta_x == nil then
        print("  Can't create first path!")
        return
    end

    next_x = x + 2 * delta_x
    next_y = y + 2 * delta_y


    repeat
        print("  Going to cut to " .. next_y .. "," .. next_x)

        maze[y + delta_y][x + delta_x] = true
        maze[next_y][next_x] = true
        x, y = next_x, next_y

        print_maze()

        delta_y, delta_x = get_deltas(y, x)
        if delta_x == nil then
            print("  Can't find anywhere to cut to")
            return
        else
            next_x = x + 2 * delta_x
            next_y = y + 2 * delta_y
        end

    until delta_x == nil

    print "Done creating path"
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
    directions = {
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
                io.write(" ")
            else
                io.write("*")
            end
        end
        io.write("\n")
    end
end

-- Generate the maze

math.randomseed( os.time() )
init()
create_paths()
print_maze()
