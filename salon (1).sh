#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"



SELECT_SERVICE() {
  # get all services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
  # display each service

  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry no can do"
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
  fi

  echo "Select service id to continue:"
  read SERVICE_ID_SELECTED

  # check if selected id is part of the available services
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo "That's not even a number"
    SELECT_SERVICE
  else
    SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SELECTED_SERVICE_NAME ]]
    then
      echo "Wrong service id provided."
      SELECT_SERVICE
    else
      #echo "Selected: $SELECTED_SERVICE_NAME"

      echo "What's your phone number?"
      read CUSTOMER_PHONE

      # check if phone number is registered by trying to get a name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "I see you're a new customer, WHATS YO NAME?"
        read CUSTOMER_NAME
        # add to the customers registry
        ADD_NEW_USER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

      echo "TELL ME DA TIME ALLREADY"
      read SERVICE_TIME

      ADD_NEW_APPOITMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');")
      echo "I have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi    
  fi  
}

SELECT_SERVICE