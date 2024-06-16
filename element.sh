#!/bin/bash
#element.sh
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
GITEMPTYVARFORCOMMIT=""
GITCHOREVAR=""

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
else
  ARG=$1
  QUERY_ATOMIC_NUMBER=$($PSQL "SELECT * FROM elements WHERE atomic_number=$ARG" 2>/dev/null)
  QUERY_SYMBOL=$($PSQL "SELECT * FROM elements WHERE symbol ILIKE '$ARG'" 2>/dev/null)
  QUERY_NAME=$($PSQL "SELECT * FROM elements WHERE name ILIKE '$ARG'" 2>/dev/null)

  CHECK_FLAG=false
  QANUM=""
  QSYM=""
  QNAM=""

  if [[ ! -z "$QUERY_ATOMIC_NUMBER" ]]; then
    CHECK_FLAG=true
    QANUM=$ARG
    QSYM=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ARG")
    QNAM=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ARG")
  elif [[ ! -z "$QUERY_SYMBOL" ]]; then
    CHECK_FLAG=true
    QSYM=$ARG
    QANUM=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ARG'")
    QNAM=$($PSQL "SELECT name FROM elements WHERE symbol='$ARG'")
  elif [[ ! -z "$QUERY_NAME" ]]; then
    CHECK_FLAG=true
    QNAM=$ARG
    QSYM=$($PSQL "SELECT symbol FROM elements WHERE name='$ARG'")
    QANUM=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ARG'")
  fi

  if [[ $CHECK_FLAG == true ]]; then
    ELE_TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) WHERE atomic_number=$QANUM")
    ELE_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$QANUM")
    MELTINGP=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$QANUM")
    BOILINGP=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$QANUM")
    echo "The element with atomic number $QANUM is $QNAM ($QSYM). It's a $ELE_TYPE, with a mass of $ELE_MASS amu. $QNAM has a melting point of $MELTINGP celsius and a boiling point of $BOILINGP celsius."
  else
    echo "I could not find that element in the database."
  fi
fi