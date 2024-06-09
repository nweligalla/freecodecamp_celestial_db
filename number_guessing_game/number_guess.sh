#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))

# echo $RANDOM_NUMBER

echo "Enter your username:"
read USERNAME

USER_RESULT=$($PSQL "SELECT username ,games_played ,best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_RESULT ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  # insert user name with default values
  GAME_PLAYED=0
  BEST_GAME=0
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username ,games_played ,best_game) VALUES ('$USERNAME',$GAME_PLAYED,$BEST_GAME)")

else
  GAME_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read NUMBER

GUESSES=1

while [ $NUMBER != $RANDOM_NUMBER ]; do

  if ! [[ "$NUMBER" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read NUMBER
  elif [ $NUMBER -gt $RANDOM_NUMBER ]; then
    echo "It's higher than that, guess again:"
    read NUMBER
  elif [ $NUMBER -lt $RANDOM_NUMBER ]; then
    echo "It's lower than that, guess again:"
    read NUMBER
  fi

  ((GUESSES++))
done

echo You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!

# update user details
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAME_PLAYED+1 WHERE username='$USERNAME'")

if [ $GUESSES -lt $BEST_GAME ] || [ $BEST_GAME == 0 ]; then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESSES WHERE username='$USERNAME'")
fi
