#!/bin/bash

function IntialVars {
    #case is irrelevant
    shopt -s nocasematch
    #retry?
    retry="y"
    #Store the selection
    carSelect=""
    #Present the user with the three types of car colors
    carType=("\e[31m#\e[0m" "\e[32m#\e[0m" "\e[34m#\e[0m")
    #obstacle car
    obstacle="\e[97m#\e[0m"
    #store the racetrack
    racingArray=("-" "-" "-" "-" "-" "-" "-" "-" "-")
    #Save the selected car type
    car=""
    #Keep track of the score
    score=0
    #Move the cars
    move=""
    inMotion=0
    #Time management
    timeAtStart=""
    currentTime=""
    #check user car pos
    userCarPos="7"
    #check previous obstacle car locations
    prevCarArray=()
    movePattern=$((1 + RANDOM % 3))
}

function LaunchScreen {
printf "\e[31m      ___           ___           ___           ___      \e[0m\n"
printf "\e[31m     /\  \         /\  \         /\  \         /\  \     \e[0m\n"
printf "\e[31m    /::\  \       /::\  \       /::\  \       /::\  \    \e[0m\n"
printf "\e[31m   /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/\ \  \   \e[0m\n"
printf "\e[32m  /:/  \:\  \   /::\~\:\  \   /::\~\:\  \   _\:\~\ \  \  \e[0m\n"
printf "\e[32m /:/__/ \:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\ /\ \:\ \ \__\ \e[0m\n"
printf "\e[32m \:\  \  \/__/ \/__\:\/:/  / \/_|::\/:/  / \:\ \:\ \/__/ \e[0m\n"
printf "\e[34m  \:\  \            \::/  /     |:|::/  /   \:\ \:\__\   \e[0m\n"
printf "\e[34m   \:\  \           /:/  /      |:|\/__/     \:\/:/  /   \e[0m\n"
printf "\e[34m    \:\__\         /:/  /       |:|  |        \::/  /    \e[0m\n"
printf "\e[34m     \/__/         \/__/         \|__|         \/__/     \e[0m\n"
sleep 5
}

function GameSetup {
    #ask for difficulty
    while [[ "$carSelect" != "1" ]] && [[ "$carSelect" != "2" ]] && [[ "$carSelect" != "3" ]];
    do
        printf "Which color would you like for your car ${carType[0]} ${carType[1]} ${carType[2]} (e.g 1,2,3)? "
        read carSelect
        car="${carType[$carSelect-1]}"
    done
 
    clear
    printf "Use A and D to control your car and avoid the cars in the way"
    sleep 2
    clear
    for i in {1..3};
    do
        printf "$i"
        sleep 1
        clear
    done

    printf "Start!"
    sleep 1
    clear

    gameLoop=1
}

#function with parameters
function MoveSelect {
    #loop through the last section of the racetrack array and find the car
    if [[ "$move" = "a" ]] || [[ "$move" = "d" ]];
    then
        for (( i=6; i<${#racingArray[@]-1}; i++ ));
        do
            if [[ ${racingArray[i]} = "$car" ]];
            then
                if [[ "$move" = "a" ]] && [[ "$((i-1))" != 5 ]];
                then
                    racingArray[i]="-"
                    racingArray[i-1]="$car"
                    userCarPos=$((i-1))
                elif [[ "$move" = "d" ]] && [[ "$((i+1))" != ${#racingArray[@]} ]];
                then
                    racingArray[i]="-"
                    racingArray[i+1]="$car"
                    userCarPos=$((i+1))
                fi
                break
            fi
        done
    fi
}


function ComputerMove {
    if [[ "$inMotion" = 0 ]];
    then
        #randomly select the move pattern
        #1-3 inclusive
        movePattern=$((1 + RANDOM % 3))
        if [[ "$movePattern" = 1 ]] || [[ "$movePattern" = 3 ]];
        then
            #randomly select the start position
            #0-2 inclusive
            #for move pattern 3 later when it reaches 3-5 add another and reset movepattern to 0
            startPos=$((RANDOM % 3))
            racingArray["$startPos"]="$obstacle"
            inMotion=1
        elif [[ "$movePattern" = 2 ]];
        then
            #randomly select the start position
            #0-2 inclusive
            #Chance of two spawning in different locations
            startPos=$((RANDOM % 3))
            racingArray["$startPos"]="$obstacle"
            startPos=$((RANDOM % 3))
            racingArray["$startPos"]="$obstacle"
            inMotion=1
        fi
    else
        carInstances=0
        #ensure that just-moved-cars are not overwritten 1
        prevCarArray=()
        for (( i=0; i<${#racingArray[@]-1}; i++ ));
        do
            #ensure that just-moved-cars are not overwritten 2
            checkPrev=$((i - 3))
            if [[ ${racingArray[i]} = "$obstacle" ]] && [[ ! "${prevCarArray[*]}" =~ "${checkPrev}" ]];
            then
                if [[ "$i" > -1 ]] && [[ "$i" < 3 ]] && [[ "$movePattern" = 3 ]];
                then
                    startPos=$((RANDOM % 3))
                    racingArray["$startPos"]="$obstacle"
                    movePattern=0
                fi 
                racingArray[i]="-"
                if [[ "$i" < 6 ]];
                then
                    racingArray[i+3]="$obstacle"
                fi 
                carInstances=$((carInstances + 1))
                prevCarArray+=("$i")
            fi
        done
        if [[ "$carInstances" = "0" ]];
        then
            inMotion=0
        fi
    fi

}

function UpdateGameBoard {
        clear
        printf "    --- --- --- \n"
        printf "   | ${racingArray[0]} | ${racingArray[1]} | ${racingArray[2]} |\n"
        printf "    --- --- --- \n"
        printf "   | ${racingArray[3]} | ${racingArray[4]} | ${racingArray[5]} |\n"
        printf "    --- --- --- \n"
        printf "   | ${racingArray[6]} | ${racingArray[7]} | ${racingArray[8]} |\n"
        printf "    --- --- --- \n"
        printf "   Score: $score\n"
}

clear
IntialVars
#show launch screen
LaunchScreen
while [[ "$retry" = "y" ]];
do
    IntialVars
    clear
    #Key functions
    GameSetup
    racingArray[7]="$car"
    UpdateGameBoard

    #initiate game
    while [[ $gameLoop = 1 ]];
    do
        #use -t to timeout after a second
        #-n1 eliminates the need to press enter to submit move
        move="."

        read -n1 -t1 move

        #prevent spam frame change
        if [[ "$move" != "." ]];
        then
            sleep 0.2
        fi

        #execute player moves
        MoveSelect
        #execute computer moves
        ComputerMove
        #update graphics
        UpdateGameBoard

        #check if game end
        if [[ "${prevCarArray[*]}" =~ "${userCarPos}" ]];
        then
            gameLoop=0
            clear
        fi
        #update score
        score=$((score+1))
        #reset move var
        move=""
    done

    clear
    #Game over text
    printf "Game Over!\n"
    printf "    $car\n"
    printf "Score: $((score-2))\n"
    printf "\n"
    #retry check
    read -p "Would you like to play again? (y/n)" retry
done