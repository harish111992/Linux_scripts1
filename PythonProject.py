import os

os.system("tput setaf 3")

print("\t\t----------------------------")
print("Welcome to the Python small script for execute some commands")

print("\t\t----------------------------")
os.system("tput setaf 7")
while True:

        print("""
                Press 1 to execute the date command
                Press 2 to execute the calander command
                Press 3 to know the ports running on the server
                Press 4 to add the new user
                Press 5 to exit""")
        print("Please enter the number: ", end='')
        nums=input()

        if int(nums)== 1:
                os.system("date")
        elif int(nums)== 2:
                os.system("cal")
        elif int(nums)== 3:
                os.system("netstat -tnlp")
        elif int(nums)== 4:
                print("please enter your username:")
                new_user=input()
                os.system("useradd {}".format(new_user))
        elif int(nums)== 5:
                exit()
        else:
                print("choose the above options only")
        input("Press Enter to continue the Menu:..")
        os.system("clear")
