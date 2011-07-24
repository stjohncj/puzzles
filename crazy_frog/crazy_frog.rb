#!/usr/bin/ruby

# A Ruby script to solve "The Crazy Frog Game" puzzle.
# This is a variation of the "One Tough Puzzle", but may predate it.
# Script by Chris St. John ~ 1/11/11

require 'pp'

GREEN       = 1
TURQUOISE   = 2
ORANGE      = 3
BLUE        = 4

$pieces = [
    [ -ORANGE, GREEN, BLUE, -TURQUOISE ],
    [ GREEN, ORANGE, -BLUE, -TURQUOISE ],
    [ GREEN, BLUE, -ORANGE, -BLUE ],
    [ GREEN, ORANGE, -GREEN, -TURQUOISE ],
    [ BLUE, ORANGE, -GREEN, -TURQUOISE ],
    [ GREEN, TURQUOISE, -ORANGE, -TURQUOISE ],
    [ BLUE, GREEN, -ORANGE, -BLUE ],
    [ BLUE, TURQUOISE, -GREEN, -ORANGE ],
    [ BLUE, TURQUOISE, -BLUE, -ORANGE ]
]
$answer = []

# Rotate piece counter-clockwise
def rotate(piece)
    piece = piece[1..3] + [piece[0]]
    return piece
end


# route
#   8 1 2
#   7 0 3
#   6 5 4

# directions
#    0
#  3   1
#    2

# Do the pieces fit together?
# Just need to test the most recently placed piece with its neighbors.
def fits(placement)
    case placement.length
    when 2
        return false if placement[0][0]  + placement[1][2]  != 0
    when 3
        return false if placement[1][1]  + placement[2][3]  != 0
    when 4
        return false if placement[2][2]  + placement[3][0]  != 0
        return false if placement[3][3]  + placement[0][1]  != 0
    when 5
        return false if placement[3][2]  + placement[4][0]  != 0
    when 6
        return false if placement[4][3]  + placement[5][1]  != 0
        return false if placement[5][0]  + placement[0][2]  != 0
    when 7
        return false if placement[5][3]  + placement[6][1]  != 0
    when 8
        return false if placement[6][0]  + placement[7][2]  != 0
        return false if placement[7][1]  + placement[0][3]  != 0
    when 9
        return false if placement[7][0]  + placement[8][2]  != 0
        return false if placement[8][1]  + placement[1][3]  != 0
    end
    return true
end


# recursively check the pieces along the route
#   8 1 2
#   7 0 3
#   6 5 4
def check(used, placement)
    if placement.length > 8 # all pieces have been checked and fit
       $answer = placement
       return true
    end
    # iterate over unused pieces and rotations (you may not need to do all rotations)
    $pieces.each_index do |pos|
        next if used[pos]
        piece = $pieces[pos]
        for i in 0..3
            this_placement = placement + [piece]
            if fits(this_placement)
                # if you find a fit, mark the piece as used and call the check for the next step
                these_used = used.clone
                these_used[pos] = true
                finished = check(these_used, this_placement)
                return true if finished
            end
            piece = rotate(piece) unless i == 3
        end
    end
    return false
end

# route
#   8 1 2
#   7 0 3
#   6 5 4
$pieces.each_index do |pos|
    used = []
    used[pos] = true
    finished = check(used, [$pieces[pos]])
    if finished
        pp $answer
        break
    end
end
