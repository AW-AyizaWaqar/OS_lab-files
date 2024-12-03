#!/bin/bash

# Color and formatting codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# Visual separator for readability
function separator() {
    echo -e "${BLUE}==========================================================${RESET}"
}
# Display game header
function game_header() {
    separator
    echo -e "${BOLD}${CYAN}                     ESCAPE ROOM                  ${RESET}"
    separator
}

# Message display with delay
function display_message() {
    local message="$1"
    echo -e "$message"
    sleep 1
}

# Room header with ASCII art for each room
function room_header() {
    local room_name="$1"
    separator
    echo -e "${CYAN}${BOLD}--- $room_name ---${RESET}"
    echo -e "${YELLOW}
 
 ______     ______     ______     ______     ______    
/\\  ___\\   /\\  ___\\   /\\  __ \\   /\\  == \\   /\\  ___\\   
\\ \\___  \\  \\ \\ \\____  \\ \\ \\/\\ \\  \\ \\  __<   \\ \\  __\\   
 \\/\\_____\\  \\ \\_____\\  \\ \\_____\\  \\ \\_____\\  \\ \\_____\\ 
  \\/_____/   \\/_____/   \\/_____/   \\/_____/   \\/_____/ ${RESET}"
    separator
}

# Countdown timer
function countdown_timer() {
    local time_left=15  # Set 15 seconds as the limit for each room
    while [ $time_left -gt 0 ]; do
        echo -ne "${RED}Time remaining: ${time_left}s${RESET}\r"
        sleep 1
        ((time_left--))
    done
    echo -e "\n${RED}Time's up! Restarting the room...${RESET}"
    echo -e "\a"  # Sound effect for time up (if supported)
}

# Inventory system
inventory=()

function add_to_inventory() {
    local item="$1"
    inventory+=("$item")
    echo -e "${GREEN}You found a $item! Added to your inventory.${RESET}"
    echo -e "\a"  # Sound effect for finding an item
}

function show_inventory() {
    echo -e "${YELLOW}Inventory: ${inventory[@]:-Nothing}${RESET}"
}

# Room 1: The Dark Room (Find the Key)
function room_1() {
    room_header "Room 1: The Dark Room"
    display_message "You are in a dark room. There is a locked door in front of you."
    display_message "You need a key to unlock it."

    # Start timer in the background
    countdown_timer &
    timer_pid=$!

    while true; do
        echo -e "\n${CYAN}Choose an action:${RESET} (1) Search room (2) Check inventory (3) Use item"
        read -rp "Your choice: " choice

        case $choice in
            1)
                echo "You search the room..."
                add_to_inventory "key"
                ;;
            2)
                show_inventory
                ;;
            3)
                if [[ " ${inventory[@]} " =~ " key " ]]; then
                    echo -e "${GREEN}You use the key to unlock the door! You can now proceed to the next room.${RESET}"
                    kill $timer_pid 2>/dev/null  # Stop the timer
                    current_room=2
                    break
                else
                    echo -e "${RED}You don't have the key yet!${RESET}"
                fi
                ;;
            *)
                echo -e "${RED}Invalid choice. Try again.${RESET}"
                ;;
        esac
    done
}

# Room 2: The Puzzle Room (Enter the Code)
function room_2() {
    room_header "Room 2: The Puzzle Room"
    display_message "A keypad blocks the door. You need to enter a 3-digit code to unlock it."

    local code="302"  # Set a 3-digit code

    # Start timer in the background
    countdown_timer &
    timer_pid=$!

    while true; do
        read -rp "Enter a 3-digit code: " guess

        if [[ "$guess" == "$code" ]]; then
            echo -e "${GREEN}Correct! The door unlocks. You can now proceed to the next room.${RESET}"
            kill $timer_pid 2>/dev/null  # Stop the timer
            current_room=3
            break
        else
            echo -e "${RED}Incorrect code. Try again.${RESET}"
        fi
    done
}

# Room 3: The Riddle Room (Answer a Riddle)
function room_3() {
    room_header "Room 3: The Riddle Room"
    display_message "To proceed, answer this riddle:"

    echo -e "\"I speak without a mouth and hear without ears. I have no body, but I come alive with wind.\""
    echo -e "${YELLOW}What am I?${RESET}"

    # Start timer in the background
    countdown_timer &
    timer_pid=$!

    while true; do
        read -rp "Your answer: " answer

        if [[ "${answer,,}" == "echo" ]]; then
            echo -e "${GREEN}Correct! You can now proceed to the next room.${RESET}"
            kill $timer_pid 2>/dev/null  # Stop the timer
            current_room=4
            break
        else
            echo -e "${RED}Incorrect answer. Try again.${RESET}"
        fi
    done
}




# Room 4: Math Riddle
function room_4() {
    room_header "Room 4: The Math Room"
    display_message "Solve this math problem to proceed:"

    echo -e "${YELLOW}What is 7 + (6 * 5) - 3?${RESET}"

    countdown_timer &
    timer_pid=$!

    while true; do
        read -rp "Your answer: " answer

        if [[ "$answer" == "34" ]]; then
            echo -e "${GREEN}Correct! You can now proceed to the next room.${RESET}"
            kill $timer_pid 2>/dev/null
            current_room=5
            break
        else
            echo -e "${RED}Incorrect answer. Try again.${RESET}"
        fi
    done
}

# Room 5: Match the Number
function room_5() {
    room_header "Room 5: Match the Number"
    display_message "Guess the number I'm thinking of (between 1 and 10):"

    local number=$((RANDOM % 10 + 1))

    countdown_timer &
    timer_pid=$!

    while true; do
        read -rp "Enter your guess: " guess

        if [[ "$guess" == "$number" ]]; then
            echo -e "${GREEN}Correct! The door unlocks. You can now proceed to the next room.${RESET}"
            kill $timer_pid 2>/dev/null
            current_room=6
            break
        else
            echo -e "${RED}Incorrect guess. Try again.${RESET}"
        fi
    done
}

# Room 6: The Missing Word Room
function room_6() {
    room_header "Room 6: The Missing Word Room"
    display_message "Complete the sentence to escape:"

    echo -e "\"The quick brown ____ jumps over the lazy dog.\""
    echo -e "${YELLOW}What word completes the sentence?${RESET}"

    countdown_timer &
    timer_pid=$!

    while true; do
        read -rp "Your answer: " answer

        if [[ "${answer,,}" == "fox" ]]; then
            echo -e "${GREEN}Correct! You've completed all the challenges and escaped!${RESET}"
            kill $timer_pid 2>/dev/null
            current_room=7
            break
        else
            echo -e "${RED}Incorrect answer. Try again.${RESET}"
        fi
    done
}

# Main Game Loop
game_header
current_room=1

while true; do
    case $current_room in
        1) room_1 ;;
        2) room_2 ;;
        3) room_3 ;;
        4) room_4 ;;
        5) room_5 ;;
        6) room_6 ;;
        *)
            separator
            echo -e "${GREEN}${BOLD}Congratulations! You've escaped the Mystery Escape Room!${RESET}"
            separator
            break
            ;;
    esac
done
