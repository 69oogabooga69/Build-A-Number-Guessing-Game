#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align --tuples-only -c"

NUMBER=$((1 + $RANDOM % 1000))
GUESSES=0

echo "Enter your username:"
read USERNAME

SEARCH_USERNAME=$($PSQL "SELECT * FROM players WHERE username='$USERNAME';")
if [[ -z $SEARCH_USERNAME ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO players(username, games_played) VALUES('$USERNAME', 1);")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played = games_played + 1 WHERE username='$USERNAME';")
  echo "$SEARCH_USERNAME" | while IFS="|" read ID NAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS != $NUMBER ]]
do
  ((GUESSES++))
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      SEARCH_BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME';")
      if [[ $GUESSES -lt $SEARCH_BEST_GAME || $SEARCH_BEST_GAME == 0 ]]
      then
        INSERT_BEST_GAME=$($PSQL "UPDATE players SET best_game=$GUESSES WHERE username='$USERNAME';")
      fi
      echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
    fi
  fi
done
