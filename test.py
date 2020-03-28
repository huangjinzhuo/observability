# Python program to execute 
# main directly 
import importtest

print("Always executed line")

if __name__ == "__main__": 
	print( "Executed when invoked directly" )
else: 
	print( "Executed when imported" )

importtest