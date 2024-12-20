#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Stephen's Salon ~~~\n\nWelcome!"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "CURRENT SERVICES:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # get user service
  echo -e "\nWhat service would you like to schedule?"
  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send back to main menu
    MAIN_MENU "That is not a valid service."
  else
    # verify id in list
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if not on list
    if [[ -z $SERVICE_ID ]]
    then
      # send to menu
      MAIN_MENU "That is not a valid service."
    else
      # send to scheduler
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
      echo -e "\nPerfect! What's your phone number?"
      # get phone number
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        # create customer
        CREATE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # get service time
      echo -e "\nWhen would you like to come in?"
      read SERVICE_TIME
      # create appointment
      APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')."
    fi
  fi
}

MAIN_MENU 
