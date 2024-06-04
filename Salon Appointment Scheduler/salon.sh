#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {

  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "\n~~~~~ MY SALON ~~~~~\n"

  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")

  #if there is no services
  if [[ -z $SERVICES ]]; then
    echo "Sorry, we don't have any service right now"
  # if there is, show them formated
  else
    echo -e "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  fi

  # get service id from user
  read SERVICE_ID_SELECTED

  # if service id not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    # send to main menu
    MAIN_MENU "Please enter a valid number! and choose again."
  else

    VALID_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

    # if user entered service number not valid
    if [[ -z $VALID_SERVICE_NAME ]]; then
      MAIN_MENU "I could not find that service. What would you like today?"
    # if its a valid service
    else

      # get customer telephone number
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # if user do not exist get the name and time
      if [[ -z $CUSTOMER_NAME ]]; then
        echo -e "I don't have a record for that phone number, what's your name?\n"
        read CUSTOMER_NAME

        # insert user to db
        ADD_USER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

        echo -e "What time would you like your color, $CUSTOMER_NAME"
        read SERVICE_TIME

        
      # if user exist get the time
      else

        echo -e "What time would you like your color, $CUSTOMER_NAME"
        read SERVICE_TIME
      fi


      #get customer id

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      echo -e "I have put you down for a $VALID_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

      # insert appointment
      APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    fi

  fi

}

MAIN_MENU
