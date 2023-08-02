#!/bin/bash

NEW_USER_ID=
PASSWORD=

while getopts "u:p:" option; do
    case $option in
        u)
            NEW_USER_ID=$OPTARG
            ;;
        p)
            PASSWORD=$OPTARG
            ;;
        *)
            echo "Please input new user name"
            echo "Usage: $0 [-u username] [-p password]"
            exit 1
            ;;
    esac
done

if [ -z "$NEW_USER_ID" ] || [ -z "$PASSWORD" ]; then
    echo "Password is required"
    echo "Usage: $0 [-u username] [-p password]"
    exit 1
fi

# user creationsㄴ
echo "Creating new user"
useradd -s /bin/bash -d /home/$NEW_USER_ID -m $NEW_USER_ID

# password change
echo "Set password"
echo "$NEW_USER_ID:$PASSWORD" | chpasswd

# user auth
echo "Update authorization"
echo "$NEW_USER_ID ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$NEW_USER_ID

# check user auth
echo "Check user auth"
cat /etc/sudoers.d/$NEW_USER_ID