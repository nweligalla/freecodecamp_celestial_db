#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

# check if arguments are empty
if [[ $# -eq 0 ]]; then
  echo Please provide an element as an argument.
else

  # check if arguments is a number or string
  if [[ $1 =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    PERIODIC_DATA=$($PSQL "SELECT atomic_number,symbol,name,atomic_mass,melting_point_celsius,boiling_point_celsius,type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1;")
  else
    PERIODIC_DATA=$($PSQL "SELECT atomic_number,symbol,name,atomic_mass,melting_point_celsius,boiling_point_celsius,type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1' OR name='$1';")
  fi

  # check if there are data in db
  if [[ -z $PERIODIC_DATA ]]; then
    echo I could not find that element in the database.

  else
    echo -e "$PERIODIC_DATA" | while read atomic_number bar symbol bar name bar atomic_mass bar melting_point_celsius bar boiling_point_celsius bar type; do
      echo -e "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
    done
  fi

fi
