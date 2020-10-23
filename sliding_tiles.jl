using Random

state = [1,2,3,4,5,6,7,8,0]

function new_game()
    shuffle!(state)
end

function display()
    for j = 1:3
        for i = 1:3
            c = state[(j-1)*3+i]
            if c == 0
                print("  ")
            else
                print(c, " ")
            end
        end
        println()
    end
end

function user_input()
    print("w|a|s|d >> ")
    user = lowercase(strip(readline(stdin)))
    if user == "w"
        idx = findfirst(isequal(0), state)
        if idx < 7
            state[idx] = state[idx+3]
            state[idx+3] = 0
        end
    elseif user == "a"
        idx = findfirst(isequal(0), state)
        if !isnothing(findfirst(isequal(idx), [1,2,4,5,7,8]))
            state[idx] = state[idx+1]
            state[idx+1] = 0
        end
    elseif user == "s"
        idx = findfirst(isequal(0), state)
        if idx > 3
            state[idx] = state[idx-3]
            state[idx-3] = 0
        end
    elseif user == "d"
        idx = findfirst(isequal(0), state)
        if !isnothing(findfirst(isequal(idx), [2,3,5,6,8,9]))
            state[idx] = state[idx-1]
            state[idx-1] = 0
        end
    elseif user == "new"
        new_game()
    elseif user == "end"
        return false
    end

    if state == [1,2,3,4,5,6,7,8,0]
        println("You won!")
        display()
        return false
    end

    return true
end

new_game()
display()
while user_input()
    display()
end
