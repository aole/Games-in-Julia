width = 10
height = 10
mines_count = 10
mines = falses(height, width)
opened = falses(height, width)

game_end = false

println("Minesweeper")

adj = [[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1]]
function mine_count(row, col)
    count = 0
    for a in adj
        r = row+a[1]
        c = col+a[2]
        if r>0 && c>0 && r<=height && c<=width && mines[CartesianIndex(r, c)] ==  true
            count += 1
        end
    end
    return count
end

function new_game()
    global mines = falses(height, width)
    global opened = falses(height, width)

    mc = mines_count
    while mc>0
        loc = rand(0:width*height-1)
        idx = CartesianIndex(loc÷height+1, loc%width+1)
        if !mines[idx]
            mines[idx] = true
            mc -= 1
        end
    end

    global game_end = false
end

function display()
    print("   ")
    for i = 1:width
        print(i, " ")
    end
    println()
    for j = 1:height
        print(lpad(j, 2, " ") * " ")
        for i = 1:width
            idx = CartesianIndex(j, i)
            if game_end && mines[idx]
                print("✽ ")
            elseif !opened[idx]
                print("◼ ")
            else
                if mines[idx]
                    print("✽ ")
                else
                    count = mine_count(j, i)
                    if count==0
                        print("◻ ")
                    else
                        print(count, " ")
                    end
                end
            end
        end
        println()
    end
    if !game_end
        println("To open: ", count(i->(!i), opened)-mines_count)
    end
end

function open(row, col)
    if !opened[CartesianIndex(row, col)]
        opened[CartesianIndex(row, col)] = true
        if count(i->(!i), opened)-mines_count == 0
            global game_end = true
            display()
            print("You won!")
        end
        if mine_count(row, col) > 0
            return
        end
        for a in adj
            r = row+a[1]
            c = col+a[2]
            if r>0 && c>0 && r<=height && c<=width
                open(r, c)
            end
        end
    end
end

function process(row, col)
    if mines[CartesianIndex(row, col)] == true
        opened[CartesianIndex(row, col)] = true
        global game_end = true
        display()
        println("You loose!")
    else
        open(row, col)
    end
end

new_game()

while !game_end
    display()
    print(">> ")
    user = strip(readline(stdin))
    if user == "end"
        global game_end = true
    else
        rc = split(user)
        if length(rc) != 2
            println("Incorrect input!")
            continue
        end
        row = parse(Int32, rc[1])
        col = parse(Int32, rc[2])
        process(row, col)
    end
end
