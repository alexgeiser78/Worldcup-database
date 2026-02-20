#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line.

$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"

while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Clean line endings
    CLEAN_WINNER=$(echo $WINNER | sed 's/\r//')
    CLEAN_OPPONENT=$(echo $OPPONENT | sed 's/\r//')
    CLEAN_ROUND=$(echo $ROUND | sed 's/\r//')

    # Insert teams
    $PSQL "INSERT INTO teams(name) VALUES('$CLEAN_WINNER') ON CONFLICT (name) DO NOTHING;"
    $PSQL "INSERT INTO teams(name) VALUES('$CLEAN_OPPONENT') ON CONFLICT (name) DO NOTHING;"

    # Get team IDs
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$CLEAN_WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$CLEAN_OPPONENT';")

    # Insert the game
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           VALUES($YEAR, '$CLEAN_ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
  fi
done < games.csv

