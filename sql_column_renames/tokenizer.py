import tokenize
tokensout = []

with tokenize.open('1.sql') as f:
    tokens = tokenize.generate_tokens(f.readline)
    for token in tokens:
        #print(token)
        #if (token.type == tokenize.NAME):
        if (token.string == "create" or token.string == 'insert'):
            #print(type(token))  
            #token.append("Hello")
            t = tokenize.TokenInfo(tokenize.NAME,  token.string.upper(), token.start, token.end, token.line)
            tokensout.append(t)
            (sline, scol) = token.end
            
            t = tokenize.TokenInfo(tokenize.NAME,  'WELCOME' , (sline, scol+1) , token.end , token.line)
            tokensout.append(t)
            #print(token.string)
            print(t.string)
        else:
            tokensout.append(token)
    with open('1.out', 'w') as o:
        o.write(tokenize.untokenize(tokensout))

            