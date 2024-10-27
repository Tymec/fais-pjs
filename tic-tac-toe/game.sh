#!/usr/bin/env bash

get_index() {
    echo $((3 * $1 + $2))
}

get_player_icon() {
    if [ $1 -eq 2 ]; then
        echo "x"
    else
        echo "o"
    fi
}

get_player_color() {
    if [ $1 -eq 2 ]; then
        echo "$(tput setaf 5)"
    else
        echo "$(tput setaf 6)"
    fi
}

get_player_name() {
    if [ $1 -eq 2 ] && [ $COM_ENABLE -eq 1 ]; then
        echo "COM"
    else
        echo "Player $1"
    fi
}

display_board() {
    # Create board with formatted cells
    local cursor=${1:--1}
    local cells=()
    for i in {0..8}; do
        local cell="-"
        if [ ${board[$i]} -ne 0 ]; then
            cell="$(get_player_icon ${board[$i]})"
        fi
        if [ $i -eq $cursor ]; then
            cell="$(get_player_color $player)$cell$(tput sgr0)"
        fi

        cells+=(" $cell")
    done
    
    # Draw the board
    echo
    echo "$(get_player_name 1): $(get_player_color 1)$(get_player_icon 1)$(tput sgr0) | $(get_player_name 2): $(get_player_color 2)$(get_player_icon 2)$(tput sgr0)"
    echo
    for i in 0 3 6; do
        printf "%3s|%3s|%3s\n" "${cells[$i]} " "${cells[$i+1]} " "${cells[$i+2]} "
        if [ $i -lt 6 ]; then
            echo "---|---|---"
        fi
    done
    echo
}

is_game_over() {
    # Check rows
    for i in 0 3 6; do
        if [ ${board[$i]} -ne 0 ] && [ ${board[$i]} -eq ${board[$i+1]} ] && [ ${board[$i+1]} -eq ${board[$i+2]} ]; then
            return 2
        fi
    done

    # Check columns
    for i in 0 1 2; do
        if [ ${board[$i]} -ne 0 ] && [ ${board[$i]} -eq ${board[$i+3]} ] && [ ${board[$i+3]} -eq ${board[$i+6]} ]; then
            return 2
        fi
    done

    # Check diagonals
    if [ ${board[0]} -ne 0 ] && [ ${board[0]} -eq ${board[4]} ] && [ ${board[4]} -eq ${board[8]} ]; then
        return 2
    fi

    if [ ${board[2]} -ne 0 ] && [ ${board[2]} -eq ${board[4]} ] && [ ${board[4]} -eq ${board[6]} ]; then
        return 2
    fi

    # Check for draw
    for cell in ${board[@]}; do
        if [ $cell -eq 0 ]; then
            return 0
        fi
    done

    # Draw
    return 1
}

is_valid_move() {
    if [ ${board[$1]} -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

get_move() {
    local cursor_x=1
    local cursor_y=1
    local msg=""

    while true; do
        clear
        display_board $(get_index $cursor_y $cursor_x)
        echo "$msg"

        # Use arrow keys to move the cursor and space to select a cell
        read -rsn1 key
        case $key in
            A)  # Up
                if [ $cursor_y -gt 0 ]; then
                    cursor_y=$((cursor_y - 1))
                fi
                ;;
            B)  # Down
                if [ $cursor_y -lt 2 ]; then
                    cursor_y=$((cursor_y + 1))
                fi
                ;;
            C)  # Right
                if [ $cursor_x -lt 2 ]; then
                    cursor_x=$((cursor_x + 1))
                fi
                ;;
            D)  # Left
                if [ $cursor_x -gt 0 ]; then
                    cursor_x=$((cursor_x - 1))
                fi
                ;;
            "")  # Select
                msg=""
                local index=$(get_index $cursor_y $cursor_x)
                if is_valid_move $index; then
                    board[$index]=$player
                    break
                else
                    msg="$(tput setaf 1)Invalid move!$(tput sgr0)"
                fi
                ;;
        esac
    done
}

get_com_move() {
    local index
    while true; do
        index=$((RANDOM % 9))
        if is_valid_move $index; then
            board[$index]=$player
            break
        fi
    done
}

save_game() {
    echo "${board[@]}" > $SAVE_FILE
    echo $player >> $SAVE_FILE
    echo "Game saved to $SAVE_FILE"
    exit 0
}

load_game() {
    local data=($(cat $1))
    board=(${data[@]:0:9})
    player=${data[9]}

    # Validate player
    if [ $player -lt 1 ] || [ $player -gt 2 ]; then
        echo "Invalid player: $player"
        exit 1
    fi

    # Validate board
    local cell_count=0
    for cell in ${board[@]}; do
        cell_count=$((cell_count + 1))
        if [ $cell -lt 0 ] || [ $cell -gt 2 ]; then
            echo "Invalid board state: $cell"
            exit 1
        fi
    done

    # Validate cell count
    if [ $cell_count -ne 9 ]; then
        echo "Invalid board cell count: $cell_count"
        exit 1
    fi

    echo "Game loaded from $1"
}

parse_args() {
    while [ $# -gt 0 ]; do
        case $1 in
            -h|--help)
                echo "Usage: $0 [-c|--com] [-l|--load <file>] [-s|--save <file>] [-p|--player <player>]"
                echo
                echo "Options:"
                echo "  -c, --com         Enable computer player"
                echo "  -l, --load <file> Load the game from a file"
                echo "  -s, --save <file> Save the game to a file"
                echo "  -p, --player <player> Set the player to start the game"
                exit 0
                ;;
            -c|--com)
                # Enable computer player
                COM_ENABLE=1
                ;;
            -l|--load)
                if [ -f $2 ]; then
                    # Load the game
                    load_game $2
                else
                    echo "Save file not found: $2"
                    exit 1
                fi
                shift
                ;;
            -s|--save)
                # Set the save file
                SAVE_FILE=$2
                shift
                ;;
            -p|--player)
                # Set the player
                player=$2
                if [ $player -lt 1 ] || [ $player -gt 2 ]; then
                    echo "Invalid player: $player"
                    exit 1
                fi
                shift
                ;;
            *)
                echo "Invalid argument: $1"
                exit 1
                ;;
        esac
        shift
    done
}

main() {
    while true; do
        if [ $player -eq 2 ] && [ $COM_ENABLE -eq 1 ]; then
            get_com_move
        else
            get_move
        fi

        clear
        display_board

        is_game_over
        local state=$?
        if [ $state -eq 2 ]; then
            echo "$(get_player_color $player)$(get_player_name $player) wins!$(tput sgr0)"
            break
        elif [ $state -eq 1 ]; then
            echo "$(tput setaf 3)It's a draw!$(tput sgr0)"
            break
        fi

        player=$((3 - player))
    done
}

# Initialize the board and randomize the player
board=(0 0 0 0 0 0 0 0 0)
player=$((RANDOM % 2 + 1))

# Parse command line arguments
COM_ENABLE=0
SAVE_FILE=""
parse_args $@

# Save the game on SIGINT
if [ -n "$SAVE_FILE" ]; then
    trap save_game SIGINT
fi

# Main game loop
main
