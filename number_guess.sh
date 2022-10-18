#!/bin/bash

## setup
# generate a random number, 1-1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
# record old IFS for read purposes
OLD_IFS=$IFS
# PSQL CLI prefix
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN(){
  ## main logic

  GET_USER
  PLAY_GAME

}

GET_USER(){
  ## get user name & ID
  # prompt for name
  echo "Enter your username:"
  read NAME

  # retrieve user ID
  ID="$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")"
  echo "Found user ID: $ID"
  # if no ID
  if [[ -z $ID ]]
  then
    # welcome new user
    echo "Welcome, $NAME! It looks like this is your first time here."
    # insert new user
    RESULT="$($PSQL "INSERT INTO users(name) VALUES('$NAME')")"
    echo $RESULT
    # get new user ID
    ID="$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")"
    echo "New ID: $ID"
    # set up default user stats
    GAMES_PLAYED=0
    BEST_GAME=""
  else
    # get user stats
    RESULT="$($PSQL "SELECT games_played,best_game FROM users WHERE user_id=$ID")"
    IFS="|"
    read GAMES_PLAYED BEST_GAME <<< $RESULT
    IFS=$OLD_IFS
    # welcome user back
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

PLAY_GAME(){
  GUESS=0
  GUESS_COUNT=1

  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  while (( $GUESS != $SECRET_NUMBER ))
  do
    # if not an integer
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      # ask for an integer
      echo "That is not an integer, guess again:"
    # if too high
    elif (( $GUESS > $SECRET_NUMBER ))
    then
      # say so
      echo "It's lower than that, guess again:"
    # if too low
    else
      # say so
      echo "It's higher than that, guess again:"
    fi
    # get new guess
    read GUESS
    # increment guess counter
    (( GUESS_COUNT++ ))
  done

  echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
}

## start the script
MAIN