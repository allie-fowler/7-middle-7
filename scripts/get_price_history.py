#!/usr/bin/python

import getopt, sys

def usage():
    print("Usage:")
    print("get_price_history.py [ -h | --help ] [ -v | --verbose ] <SYMBOL>")

def lookup(my_symbol):
    from googlefinance.get import get_datum
    df = get_datum(my_symbol, period='11Y'， interval =86400)
    print(df)

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ho:v", ["help", "output="])
    except getopt.GetoptError as err:
        # print help information and exit:
        print(err)  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    symbol = ""
    verbose = False
    for o, a in opts:
        if o == "-v":
            verbose = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit()
        else:
            symbol = a
    
    if symbol == "":
          usage()
          sys.exit()
          
    lookup(symbol.upper()) 

if __name__ == "__main__":
    main()

