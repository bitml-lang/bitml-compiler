parts = ["A0", "A1", "A2", "A3", "A4"]
secs = ["a0", "a1", "a2", "a3", "a4"]

n = len(parts)

def bitfield(i):
    l =  [int(digit) for digit in bin(i)[2:]] # [2:] to chop off the "0b" part 
    return ([0] * (n - len(l))) + l

def C(i,p):      
    if i < n-1:  
        print "(define C" + str(i) + str(p) + " (sum (reveal (" + secs[i] + ") (ref C" + str(i+1) + str(p+pow(2,i)) + ")) (after " + str(10*(i+1)) + " (tau (ref C" + str(i+1) + str(p) + ")))))\n"
        C(i+1, p+pow(2,i))
        C(i+1, p)
    else:
        print "(define C" + str(i) + str(p) + " (sum (reveal (" + secs[i] + ") (ref W" +  str(p+pow(2,i)) + ")) (after " + str(10*(i+1)) + " (ref W" + str(p) + "))))\n"

def W(i):

    if i==0:
        out = "(define W0 \n (split "
        for i in range(n):
            out += "(1 -> (withdraw \"" + parts[i] + "\"))"

    else:
        bits = bitfield(i)
        bits.reverse()
        sec_revealed = sum(bits)

        out = "(define W" + str(i) + "\n (split "

        for i in range(n):
            if bits[i] == 1:
                out += "(" + str(n/(sec_revealed*1.0)) + " -> (withdraw \"" + parts[i] + "\"))"

    out += "))\n"
    print out

C(0,0)

for i in range(pow(2,n)):
    W(i)
