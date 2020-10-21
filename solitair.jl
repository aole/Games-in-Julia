#=
Solitair
Bhupendra Aole
10/20/2020
=#
using Random

#= cards:
    ♠ 1:13
    ♡ 14:26
    ♣ 27:39
    ♢ 40:52
=#
CARD = ["A♠", "2♠", "3♠", "4♠", "5♠", "6♠", "7♠", "8♠", "9♠", "T♠", "J♠", "Q♠", "K♠",
        "A♡", "2♡", "3♡", "4♡", "5♡", "6♡", "7♡", "8♡", "9♡", "T♡", "J♡", "Q♡", "K♡", 
        "A♣", "2♣", "3♣", "4♣", "5♣", "6♣", "7♣", "8♣", "9♣", "T♣", "J♣", "Q♣", "K♣",
        "A♢", "2♢", "3♢", "4♢", "5♢", "6♢", "7♢", "8♢", "9♢", "T♢", "J♢", "Q♢", "K♢"]
SUIT = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,]
BACK = ["▮ ¹", "▮ ²", "▮ ³", "▮ ⁴", "▮ ⁵", "▮ ⁶", "▮ ⁷", "▮ ⁸", "▮ ⁹", "▮ ¹⁰",
        "▮ ¹¹", "▮ ¹²", "▮ ¹³", "▮ ¹⁴", "▮ ¹⁵", "▮ ¹⁶", "▮ ¹⁷", "▮ ¹⁸", "▮ ¹⁹", "▮ ²⁰",
        "▮ ²¹", "▮ ²²", "▮ ²³", "▮ ²⁴"]
# card stacks
closed = []
opened = []
completed = [[], [], [], []] # 4 completed stacks
lane = [[], [], [], [], [], [], []] # 7 stacks for closed in lane
working = [[], [], [], [], [], [], []] # 7 working stacks open over lane

function new_game()
    deck = Array(1:52)
    shuffle!(deck)
    for i in 1:7
        for j in 1:i-1
            push!(lane[i], pop!(deck))
        end
        push!(working[i], pop!(deck))
    end
    global closed = deck
end

function display()
    println()
    println("------------------")
    println("X\tO\t\tA\tB\tC\tD")
    # closed stack
    if length(closed)>0
        print(BACK[length(closed)], "\t")
    else
        print("\t")
    end
    # opened stack
    if length(opened)>0
        print(CARD[opened[length(opened)]], "\t\t")
    else
        print("\t\t")
    end
    for c in completed
        if length(c)>0
            print(CARD[c[length(c)]], "\t")
        else
            print("\t")
        end
    end
    println("\n")
    println("1\t2\t3\t4\t5\t6\t7")
    l = deepcopy(lane)
    w = deepcopy(working)

    # first row
    for i = 1:7
        if length(l[i])>0
            print(BACK[length(l[i])], "\t")
        else
            if length(w[i])>0
                wn = popfirst!(w[i])
                print(CARD[wn], "\t")
            else
                print("\t")
            end
        end
    end
    println()

    # reset of the rows
    conti = true
    while conti
        conti = false
        for i = 1:7
            if length(w[i])>0
                wn = popfirst!(w[i])
                print(CARD[wn], "\t")
                conti = true
            else
                print("\t")
            end
        end
        println()
    end
end

function push_all(s, c)
    if isa(c, Array)
        while length(c)>0
            push!(s, popfirst!(c))
        end
    else
        push!(s, c)
    end
end

function place(cards) # card
    # check if it is a single card or an array with a single card
    if isa(cards, Array) && length(cards)==1
        cards = cards[1]
    end

    if isa(cards, Array)
        c = cards[1]
    else # try completed stack if single card is placed
        c = cards
        if c % 13 == 1 # ACE
            for i = 1:4
                if length(completed[i]) == 0
                    push_all(completed[i], c)
                    return true
                end
            end
        else
            for i = 1:4
                if length(completed[i]) > 0 && completed[i][length(completed[i])]+1 == c
                    push_all(completed[i], c)
                    return true
                end
            end
        end
    end

    # check lanes
    for i = 1:7
        if c%13==0 && length(lane[i])==0 && length(working[i])==0 # place king
            push_all(working[i], cards)
            return true
        elseif length(working[i])>0 && working[i][length(working[i])]%13 == (c+1)%13
            # check suit
            t = working[i][length(working[i])]
            if SUIT[t] != SUIT[c]
                push_all(working[i], cards)
                return true
            end
        end
    end

    return false
end

function is_win()
    for i = 1:7
        if length(lane[i]) != 0
            return false
        end
    end
    return true
end

println("Solitair")
new_game()
while true
    display()
    print(">> ")
    reply = lowercase(strip(readline()))
    
    if length(reply)==0 || reply == "x"
        if length(closed)>0
            push!(opened, pop!(closed))
        else
            global closed = reverse(opened)
            global opened = []
            push!(opened, pop!(closed))
        end
    elseif reply == "end"
        break
    elseif reply == "o"
        if length(opened)>0
            p = opened[length(opened)]
            if place(p)
                pop!(opened)
            end
        end
    elseif length(reply) == 2
        if occursin(reply[1], "1234567")
            if occursin(reply[2], "123456789")
                l = parse(Int32, reply[1])
                w = working[l]
                if length(w)>0
                    n = parse(Int32, reply[2]) # only take these many cards from the top of the stack
                    if place(w[length(w)-(n-1):length(w)])
                        for i = 1:n
                            pop!(w)
                        end
                        if length(lane[l]) > 0 && length(w) == 0
                            push!(w, pop!(lane[l]))
                        end
                    end
                end
            end
        end
    elseif occursin(reply, "1234567")
        l = parse(Int32, reply)
        w = working[l]
        if length(w)>0
            if place(w)
                empty!(w)
                if length(lane[l])>0
                    push!(w, pop!(lane[l]))
                end
            end
        end
    elseif occursin(reply, "abcd")
        w = completed[Int(reply[1])-96]
        if length(w)>0
            if place(w[length(w)])
                pop!(w)
            end
        end
    end

    if is_win()
        display()
        println("You Win!")
        break
    end
end
