#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
MAIN_MENU() {
echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME BAR
  do
    echo "$SERVICE_ID) $NAME"
  done
echo -e "\nWhich service would you like to book? Please enter a number."
read SERVICE_ID_SELECTED
}
MAIN_MENU
SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $SERVICE_AVAILABILITY ]]
then
  MAIN_MENU
else
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    echo -e "\nWhat time would you like your $SERVICE_AVAILABILITY, $CUSTOMER_NAME?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")
    echo -e "\nI have put you down for a $SERVICE_AVAILABILITY at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nWhat time would you like your $SERVICE_AVAILABILITY, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")
    echo -e "\nI have put you down for a $SERVICE_AVAILABILITY at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi