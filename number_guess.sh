#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\nEnter your username:"
read USERNAME

FIND_USER_ID=$($PSQL "SELECT user_id FROM guesses WHERE username = '$USERNAME'")
if [[ -z $FIND_USER_ID ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  NUM_GAMES=$($PSQL "SELECT num_games FROM guesses WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM guesses WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $NUM_GAMES games, and your best game took $BEST_GAME guesses."
fi

RANDOM_NUMBER=$(( RANDOM % 1000 + 1))

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESSED_NUM

NUM_COUNT=1

while [ $GUESSED_NUM != $RANDOM_NUMBER ]
do
  if [[ ! $GUESSED_NUM =~ ^[0-9]+$ ]]
  then
  echo -e "\nThat is not an integer, guess again:"
  let NUM_COUNT++
  read GUESSED_NUM
  elif [[ $GUESSED_NUM -lt $RANDOM_NUMBER ]]
  then
  echo -e "\nIt's higher than that, guess again:"
  let NUM_COUNT++
  read GUESSED_NUM
  elif [[ $GUESSED_NUM -gt $RANDOM_NUMBER ]]
  then
  echo -e "\nIt's lower than that, guess again:"
  let NUM_COUNT++
  read GUESSED_NUM
  fi
done

if [[ -z $FIND_USER_ID ]]
then
  ADD_NEW_USER=$($PSQL "INSERT INTO guesses(username,num_games,best_game) VALUES('$USERNAME',1,$NUM_COUNT)")
else
  let NUM_GAMES++
  if [[ $NUM_COUNT -lt $BEST_GAME ]]
  then
  BEST_GAME=$NUM_COUNT
  UPDATE_USER_1=$($PSQL "UPDATE guesses SET num_games = $NUM_GAMES WHERE username = '$USERNAME'")
  UPDATE_USER_2=$($PSQL "UPDATE guesses SET best_game = $BEST_GAME WHERE username = '$USERNAME'")
  else
  UPDATE_USER_1=$($PSQL "UPDATE guesses SET num_games = $NUM_GAMES WHERE username = '$USERNAME'")
  fi
fi
echo -e "You guessed it in $NUM_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
#echo -e "You guessed it in <number_of_guesses> tries. The secret number was <secret_number>. Nice job!"






