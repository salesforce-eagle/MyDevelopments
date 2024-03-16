public class CTX_CustomEvaluateString
{
    public static Decimal evaluate(String expression)
    {
        List<String> tokens = expression.Split(' ');
        system.debug('Token^&& :'+ tokens);
        
        // Stack for numbers: 'values'
        Stack values = new Stack();
        
        // Stack for Operators: 'ops'
        Stack ops = new Stack();
        Boolean roundCheck = FALSE;
        for (integer i = 0; i < tokens.size(); i++)
        {
            system.debug('tokens[i]'+ i +':'+ tokens[i]) ;
            // Current token is a
            // whitespace, skip it
            if (tokens[i] == ' ')
                continue;
            
            // Current token is a number,
            // push it to stack for numbers
            if (tokens[i] >= '0' &&
                tokens[i] <= '99999999999999999999999999')
            {
                List<String> sbuf = new
                    List<String>();
                
                // There may be more than one
                // digits in number
                while (i < tokens.size() &&
                       tokens[i] >= '0' &&
                       tokens[i] <= '99999999999999999999999999'){
                           sbuf.add(tokens[i++]);
                           system.debug('sbuf&^&'+sbuf);
                           Decimal valToBePushed = Decimal.ValueOf(String.ValueOf(sbuf).remove('(').remove(')'));
                           system.debug('valToBePushed&^&'+valToBePushed);
                           values.push(valToBePushed);
                           
                       }
                
                // right now the i points to
                // the character next to the digit,
                // since the for loop also increases
                // the i, we would skip one
                //  token position; we need to
                // decrease the value of i by 1 to
                // correct the offset.
                i--;
            }
            
            // Current token is an opening brace,
            // push it to 'ops'
            else if (tokens[i] == '(' ){
                ops.push(tokens[i]);
            }
            /**else if (tokens[i] == 'ROUND{' ){
ops.push(tokens[i]);
}**/
            // Closing brace encountered,
            // solve entire brace
            else if (tokens[i] == ')' )
            {
                while (ops.peek() != '(' ){
                    Decimal toRound = applyOp(String.ValueOf(ops.pop()),
                                              (Decimal)(values.pop()),
                                              (Decimal)(values.pop()));
                    system.debug('Gtest#$$$%'+toRound);
                    values.push(toRound);
                }
                ops.pop();
            }
            /** else if (tokens[i] == '}'){
while (ops.peek() != 'ROUND{' ){
Decimal toRound = applyOp(String.ValueOf(ops.pop()),
(Decimal)(values.pop()),
(Decimal)(values.pop()));
system.debug('Gtest#$$$%'+toRound);
toRound = toRound > 9999 ? (toRound/10000).setScale(0) * 10000 : toRound ;
values.push(toRound);
}
ops.pop();
}**/
            
            
            
            // Current token is an operator.
            else if (tokens[i] == '+'  ||
                     tokens[i] == '-'  ||
                     tokens[i] == '*'  ||
                     tokens[i] == '/'  ||
                     tokens[i] == '==' ||
                     tokens[i] == '>=' ||
                     tokens[i] == '<=' ||
                     tokens[i] == '<'  ||
                     tokens[i] == '>'  ||
                     tokens[i] == '!=' ||
                     tokens[i] == '&&' ||
                     tokens[i] == '||'
                    )
            {
                // While top of 'ops' has same
                // or greater precedence to current
                // token, which is an operator.
                // Apply operator on top of 'ops'
                // to top two elements in values stack
                while (!ops.isEmpty() &&
                       hasPrecedence(tokens[i],
                                     String.ValueOf(ops.peek()))){
                                         
                                         
                                         Decimal valueToBePushed = applyOp(String.ValueOf(ops.pop()),
                                                                           (Decimal)(values.pop()),
                                                                           (Decimal)(values.pop()));
                                         system.debug('value123##$'+valueToBePushed);
                                         values.push(valueToBePushed);
                                     }
                // Push current token to 'ops'.
                ops.push(tokens[i]);
            }
        }
        
        // Entire expression has been
        // parsed at this point, apply remaining
        // ops to remaining values
        while (!ops.isEmpty()){
            system.debug('ops%%'+ops);
            values.push(applyOp(String.ValueOf(ops.pop()),
                                (Decimal)(values.pop()),
                                (Decimal)(values.pop())));
            
        }
        
        // Top of 'values' contains
        // result, return it
        
        Decimal returnValue= (Decimal)(values.pop());
        system.debug ('valueReturn' + returnValue);
        return returnValue;
    }
    
    // Returns true if 'op2' has higher
    // or same precedence as 'op1',
    // otherwise returns false.
    public static boolean hasPrecedence(
        String op1, String op2)
    {
        if (op2 == '(' || op2 == ')' /**|| op2 == 'ROUND{' || op2 == '}'**/)
            return false;
        if ((op1 == '*' || op1 == '/') &&
            (op2 == '+' || op2 == '-'))
            return false;
        if ((op1 == '*' || op1 == '/' || op1 == '+' || op1 == '-') &&
            (op2 == '>' || op2 == '<' || op2 == '==' || op2 == '!=' || op2 == '>=' || op2 == '<='))
            return false;
        if ((op1 == '>' || op1 == '<' || op1 == '==' || op1 == '!=' || op1 == '>=' || op1 == '<=' || op1 == '*' || op1 == '/' || op2 == '+' || op2 == '-') &&
            (op2 == '||' || op2 == '&&'))
            return false;
        else
            return true;
    }
    
    // A utility method to apply an
    // operator 'op' on operands 'a'
    // and 'b'. Return the result.
    public static Decimal applyOp(String op,
                                  Decimal b, Decimal a)
    {
        Decimal boolResult;
        switch on op 
        {
            when '+'{
                return a + b;
            }
            when '-'{
                return a - b;
            }
            when '*'{
                return a * b;
            }
            when '/'{
                if (b == 0)
                    throw new
                    UnsupportedOperationException(
                        'Cannot divide by zero');
                return a / b;
            }
            when '=='{
                return(a == b ?  1 : 0);
            }
            when '!='{
                return(a != b ?  1 : 0);
            }
            when '>'{
                return(a > b ?  1 : 0);
            }
            when '<'{
                return(a < b ?  1 : 0);
            }
            when '>='{
                return(a >= b ?  1 : 0);
            }
            when '<='{
                return(a <= b ?  1 : 0);
            }  
            when '||'{
                return(a==1 || b==1 ?  1 : 0);
            }
            when '&&'{
                return(a==1 && b==1 ?  1 : 0);
            }
        }
        
        return 0;
    }
}