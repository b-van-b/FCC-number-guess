#!/bin/bash

## setup
# generate a random number, 1-1000
RND=$(( $RANDOM % 1000 + 1 ))
# record old IFS for read purposes
OLD_IFS=$IFS
# PSQL CLI prefix
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN(){
  ## main logic

  GET_USER

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



## start the script
MAIN