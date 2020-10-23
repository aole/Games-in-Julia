# GO

TESTING = false

blank = 1
black = 2
white = 3
stone = [".", "⚈", "⚆"]

size = 9

state = ones(Int8, size*size)
move = black
passes = 0
last_captured = []

function msg(s)
    if !TESTING
        println(s)
    end
end

function set_game(blacks, whites, moveof)
    new_game()
    global move = moveof
    for m in blacks
        col = Int(m[1]) - 96
        row = size - parse(Int8, m[2])
        state[row*size+col] = black
    end
    for m in whites
        col = Int(m[1]) - 96
        row = size - parse(Int8, m[2])
        state[row*size+col] = white
    end
end

function set_move(moveof)
    global move = moveof
end

function new_game()
    global state = ones(Int8, size*size)
    global move = black
    global passes = 0
end

function display()
    println()
    println("  a  b  c  d  e  f  g  h  i")
    for j = 0:size-1
        print(size-j, " ")
        for i = 1:size
            print(stone[state[j*size+i]])

            if i != size
                print("  ")
            end
        end
        print(" ", size-j)
        println()
        print("  ")
        if j != size-1
            for i = 1:size
                print("   ")
            end
            println()
        end
    end
    println("a  b  c  d  e  f  g  h  i")
end

function is_in_bounds(row, col)
    return col>0 && col<=size && row>=0 && row<size
end

function is_surrounded(row, col, moveof, vg = Nothing)
    if vg === Nothing vg = zeros(size*size) end
    oppo = moveof==black ? white : black

    idx = row*size+col
    vg[idx] = 1 # this cell has been visited

    # quick check: this cell is surrounded
    if (col+1>size || state[row*size+col+1]==oppo) &&
        (col-1<=0 || state[row*size+col-1]==oppo) &&
        (row+1>=size || state[(row+1)*size+col]==oppo) &&
        (row-1<0 || state[(row-1)*size+col]==oppo)
        return true
    end

    # recursively check adjacent cells
    adj = [[-1,0], [1,0], [0, -1], [0, 1]]
    for a in adj
        acol = col+a[1]
        arow = row+a[2]
        if !is_in_bounds(arow, acol) continue end

        # dont check already visited ones
        if vg[arow*size+acol] == 1 continue end

        # found a liberty?
        if state[arow*size+acol] == blank return false end

        # opposition stone?
        if state[arow*size+acol] == oppo continue end

        # same colored stone, so recurse
        if !is_surrounded(arow, acol, moveof, vg) return false end
    end

    return true
end

function is_capturing(row, col)
    oppo = move==black ? white : black
    vg = zeros(size*size)
    vg[row*size+col] = 1 # do not check this cell
    # recursively check adjacent cells
    adj = [[-1,0], [1,0], [0, -1], [0, 1]]
    for a in adj
        acol = col+a[1]
        arow = row+a[2]
        if !is_in_bounds(arow, acol) continue end
        if is_surrounded(arow, acol, oppo, vg) return true end
    end
    return false
end

function is_legal(row, col)
    if !is_in_bounds(row, col) return false end
    if state[row*size+col] != blank return false end
    if is_surrounded(row, col, move)
        if is_capturing(row, col)
            if length(last_captured) == 1 && last_captured[1] == row*size+col
                msg("KO not allowed!")
                return false
            else return true end
        else
            msg("Move is illigal (captured). Also not a capturing move!")
            return false 
        end
    end

    return true
end

function stone_on(m)
    col = Int(m[1]) - 96
    row = size - parse(Int8, m[2])
    return state[row*size+col]
end

function update_board()
    empty!(last_captured)

    # mark stones to remove
    for row = 0:size-1
        for col = 1:size
            if state[row*size+col]==move && is_surrounded(row, col, move)
                push!(last_captured, row*size+col)
            end
        end
    end

    # remove stones
    for i in last_captured
        state[i] = blank
    end
end

function process_input(m)
    col = Int(m[1]) - 96
    row = size - parse(Int8, m[2])
    if is_legal(row, col)
        state[row*size+col] = move
        
        global move = move==black ? white : black
        global passes = 0

        update_board()

        return true
    end
    return false
end

function search_pocket(p, row, col, vg)
    idx = row*size+col
    if state[idx]==blank
        push!(p, idx)
    else
        return state[idx]
    end

    vg[idx] = 1
    m = state[idx]
    adj = [[-1,0], [1,0], [0, -1], [0, 1]]
    for a in adj
        acol = col+a[1]
        arow = row+a[2]
        if !is_in_bounds(arow, acol) continue end
        if vg[arow*size+acol] == 1 continue end
        ms = search_pocket(p, arow, acol, vg)
        if ms!=m && ms!=blank && m!=blank
            return 4
        end
        if ms!=blank
            m = ms
        end
    end
    return m
end

function calculate_score()
    score = [0, 0, 0, 0] # blank/black/white scores
    vg = zeros(size*size)
    for row = 0:size-1
        for col = 1:size
            idx = row*size+col
            if vg[idx]==1 continue end
            if state[idx] == blank
                pocket = []
                m = search_pocket(pocket, row, col, vg)
                score[m] += length(pocket)
            else
                score[state[idx]] += 1
            end
        end
    end
    return score
end

function user_input()
    score = calculate_score()
    println(stone[black], " :", score[black], ". ", stone[white], " :", score[white])
    print("place ", stone[move], " >> ")
    user = lowercase(strip(readline()))
    if user == "end"
        return false
    elseif user == "pass"
        global passes += 1
        if passes==2
            return false
        end
        global move = move==black ? white : black
    elseif length(user) == 2
        if occursin(user[1], "abcdefghi") && occursin(user[2], "123456789")
            process_input(user)
        elseif occursin(user[2], "abcdefghi") && occursin(user[1], "123456789")
            process_input(user[2]*user[1])
        end
    end

    return true
end

if !TESTING
    println("GO")
    new_game()
    display()
    while user_input()
        display()
    end
    score = calculate_score()
    if score[black]>score[white]
        println("Blacks wins!")
    elseif score[white]>score[black]
        println("White win!")
    else
        println("Draw!")
    end
end
