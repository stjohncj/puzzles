#!/usr/bin/ruby

# A Ruby script to solve the "One Tough Puzzle"™ by the Great American Puzzle Factory.
# Script by Chris St. John ~ 1/1/11

# Usage:
#  ruby one_tough_puzzle.rb -v # verbose
#  ruby one_tough_puzzle.rb -r # restart with read of start value from last_processed_piece.txt text file that is written on SIGINT.
#  ruby one_tough_puzzle.rb 543216789 # set start value from command-line


require 'pp'

verbose = false
# The starting position of the pieces, to allow termination of execution and restart at last position.
start = 123456789
ARGV.each do |argv|
    if argv == '-v'
        verbose = true
    elsif argv == '-r'
        File.open('last_processed_piece.txt', 'r') do |f|
            start = f.gets.chomp.to_i
        end
        puts 'Starting from last value of ' + start.to_s + '.'
    else
        begin
            start = argv.to_i
        rescue
            puts "Bad argument: #{argv}."
            exit!
        end
    end
end

CLUBS       = 1
DIAMONDS    = 2
HEARTS      = 3
SPADES      = 4

pieces = [
    [ SPADES, DIAMONDS, -HEARTS, -DIAMONDS ],
    [ SPADES, DIAMONDS, -SPADES, -HEARTS ],
    [ CLUBS, HEARTS, -DIAMONDS, -CLUBS ],
    [ HEARTS, DIAMONDS, -DIAMONDS, -HEARTS ],
    [ CLUBS, HEARTS, -SPADES, -HEARTS ],
    [ DIAMONDS, CLUBS, -CLUBS, -DIAMONDS ],
    [ HEARTS, DIAMONDS, -CLUBS, -CLUBS ],
    [ SPADES, SPADES, -HEARTS, -CLUBS ],
    [ HEARTS, SPADES, -SPADES, -CLUBS ]
]

# Rotate piece counter-clockwise
def shift(piece)
    piece = piece[1..3] + [piece[0]]
    return piece
end

#    0, 1, 2,
#    3, 4, 5,
#    6, 7, 8

#    0
#  3   1
#    2

# Do the pieces all fit together?
def test(pieces)
    return false if pieces[0][1]  + pieces[1][3]  != 0
    return false if pieces[1][1]  + pieces[2][3]  != 0
    return false if pieces[0][2]  + pieces[3][0]  != 0
    return false if pieces[1][2]  + pieces[4][0]  != 0
    return false if pieces[2][2]  + pieces[5][0]  != 0
    return false if pieces[3][1]  + pieces[4][3]  != 0
    return false if pieces[4][1]  + pieces[5][3]  != 0
    return false if pieces[3][2]  + pieces[6][0]  != 0
    return false if pieces[4][2]  + pieces[7][0]  != 0
    return false if pieces[5][2]  + pieces[8][0]  != 0
    return false if pieces[6][1]  + pieces[7][3]  != 0
    return false if pieces[7][1]  + pieces[8][3]  != 0
    return true
end


n = nil # Establish scope to allow storage of n val on interrupt.

trap 'SIGINT' do
    File.open('last_processed_piece.txt', 'w') do |f|
        f.puts n.to_s
    end
    exit!
end


# We are numbering the puzzle pieces from 1 to 9.  We can then iterate over all 
# numbers between 123456789 and 987654321 where each digit is unique and a member
# of {1, 2, 3, 4, 5, 6, 7, 8, 9} in order to test each possible layout of pieces.
for n in start..987654321
    
    sum = 0 # The sum of the digits is 45 when we have a permutation of [1,2,3,4,5,6,7,8,9].
    position = [] # This will be an array of digits representing the puzzle piece numbers.
    i = n
    9.times do
        digit = i.modulo(10)
        if digit == 0 # zero is not a valid puzzle piece number for our method of solving the puzzle
           sum = 0 # Let's fail the check on this number and go to the next.
           break
        end
        if position.include?(digit) # We need each digit to be unique.
            sum = 0 # Let's fail the check on this number and go to the next.
            break
        end
        position << digit  # We have a unique digit, add it to our position array to be used later.
        sum += digit
        i /= 10
    end
    next unless (sum == 45)
    position.reverse!
    
    print "#{n}"
    STDOUT.flush
    for c in 0..262143 # 262143 is 333333333 base 4
        config = []
        # Using some modulo / base 4 magic here to represent the turning of a piece through its four positions.
        j = c
        (0..8).each do |i|
            config_piece = pieces[position[i] - 1]
            j.modulo(4).times { config_piece = shift(config_piece) }
            j /= 4
            config << config_piece
        end
        if verbose && c.modulo(10000) == 0
            print '.'
            STDOUT.flush
        end
        success = test(config)
        if success
            puts "Success!" if verbose
            pp config
            exit
        end
    end
    print "\n"
end
