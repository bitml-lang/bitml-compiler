parts = ["A", "B", "C", "D"]
secs = ["a", "b", "c", "d"]

n = len(parts)

def bitfield(i):
    l =  [int(digit) for digit in bin(i)[2:]] # [2:] to chop off the "0b" part 
    return ([0] * (n - len(l))) + l

def C(i,p):      
    if i < n-1:  
        return "(reveal (" + secs[i] + ") (sum \n" + C(i+1, p+pow(2,i)) + "\n (after " + str(10*(i+1)) + " " +C(i+1, p) + ")))"
    else:
        return "(reveal (" + secs[i] + ") (sum \n" +  W(p+pow(2,i)) + "\n (after " + str(10*(i+1)) + "\n " + W(p) + ")))"

def W(i):

    out = "(split "

    if i==0:
        for i in range(n):
            out += "(1 -> (withdraw \"" + parts[i] + "\"))"

    else:
        bits = bitfield(i)
        bits.reverse()
        sec_revealed = sum(bits)

        out = "(split "

        for i in range(n):
            if bits[i] == 1:
                out += "(" + str(n/(sec_revealed*1.0)) + " -> (withdraw \"" + parts[i] + "\"))"

    out += ")"
    return out

print C(0,0)
