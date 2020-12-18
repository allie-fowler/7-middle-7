#!/usr/bin/python

import getopt
import sys


def usage():
    print("Usage:")
    print("get_price_history.py [ -h | --help ] [ -v | --verbose ] -s <SYMBOL>")


def lookup(my_symbol):
    print("Local symbol is ", my_symbol)
    from googlefinance.get import get_code('NASDAQ')
    from googlefinance.get import get_datum
    df = get_datum(my_symbol, period='11M', interval=86400)
    print(df)


def main():
    symbol = ""
    verbose = False
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hs:v", ["help", "symbol="])
        print('Opts are ')
        print(opts)
        print('Args are ')
        print(args)
    except getopt.GetoptError as err:
        # print help information and exit:
        print(err)  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == "-v":
            verbose = True
        elif opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-s", "--symbol="):
            symbol = arg
        else:
            assert False, "unhandled option"
            usage()
            sys.exit

    if verbose:
        print('Option is: ', opt)
        print('Argument is: ', arg)
        print('Symbol is : ', symbol)

    if symbol == "":
        usage()
        sys.exit()

    lookup(symbol.upper())


if __name__ == "__main__":
    main()
