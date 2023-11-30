grammar UTL;

// ---Lexer rules---

// Keywords
MAIN:     'Main';
FOR:      'for';
WHILE:    'while';
RETURN:   'return';
IF:       'if';
ELSE:     'else';

// Basic Types
SHARED:    'shared';
STATIC:    'static';
INT:       'int';
FLOAT:     'float';
DOUBLE:    'double';
STRING:    'string';
BOOL:      'bool';
VOID:      'void';

// Controlers
BREAK:     'break';
CONTINUE:  'continue';

// Special Functions
ONSTART:    'OnStart';
ONINIT:     'OnInit';
REFRESHRATE:'RefreshRate';
TERMINATE:  'Terminate';
CONNECT:    'Connect';
OBSERVE:    'Observe';
PRINT:      'Print';
GETCANDLE:  'GetCandle';


//Special Method Function
CLOSE_METHOD : 'close()';
OPEN_METHOD : 'open()';


// TIMING
SCHEDULE:   '@schedule';
PREORDER:   'Preorder';
PARALLEL:   'parallel';

// Special Valriabels
TYPE:      'Type';
ASK:       'Ask';
BID:       'Bid';
SELL:      'SELL';
BUY:       'BUY';
VOLUME:    'Volume' ;
LOW:       'Low';
HIGH:      'High';
CLOSE:     'Close';
OPEN:      'Open';
TIME:      'Time';

// Candle
CANDLE:    'Candle';

// Order
ORDER:     'Order';


// Trade
TRADE:     'Trade';

// Exeptions
TRY:       'try';
CATCH:     'catch';
THROW:     'throw';
EXCEPTION: 'Exception';

// Type Values
ZERO:        '0';
INT_VAL:     [1-9][0-9]*;
FLOAT_VAL:   INT_VAL '.' [0-9]+ | '0.' [0-9]*;
DOUBLE_VAL:  INT_VAL '.' [0-9]+ | '0.' [0-9]*;
BOOLEAN_VAL: 'true' | 'false';
STRING_VAL:  DOUBLEQUOTE [a-zA-Z][a-zA-Z0-9_]* DOUBLEQUOTE ;

// Parenthesis
LPAR: '(';
RPAR: ')';

// Brackets (array element access)
LBRACKET: '[';
RBRACKET: ']';

// Relational Operators
GTR: '>';
LES: '<';
EQL: '==';
NEQ: '!=';

// Arithmetic Operators
PLUS:       '+';
MINUS:      '-';
PLUSPLUS:   '++';
MINUSMINUS: '--';
MULT:       '*';
DIV:        '/';
MOD:        '%';

// Logical Operators On bool
AND: '&&';
OR:  '||';
NOT: '!';

// Logical Operators On number
NOTBITWISE:     '~';
RSHIFT:     '>>';
LSHIFT:     '<<';
ANDBITWISE: '&';
ORBITWISE:  '|';
XOR:        '^';

// Assignment Operators
ASSIGN:     '=';
PLUSASIGN:  '+=';
MINUSASIGN: '-=';
MULTASIGN:  '*=';
DIVASIGN:   '/=';
MODASIGN:   '%=';

// Symbols
LBRACE:    '{';
RBRACE:    '}';
COMMA:     ',';
DOT:       '.';
COLON:     ':';
QUESTION:  '?';
SEMICOLON : ';';
DOUBLEQUOTE:'"';

// Other
IDENTIFIER: [a-zA-Z][a-zA-Z0-9_]*;
ARROW:      '=>';
LINECOMMENT:'//' ~[\r\n]* -> skip;
MULTICOMMENT:    '/*' .*? '*/' -> skip;
WS:         [ \t\r\n]+ -> skip;




// Parser rules
program
    :
    (globalVars | sharedVars)* (oSoIfunction | function)* main (comment)*
    ;

main
    :
    (type | VOID)
    MAIN
    LPAR RPAR LBRACE
    body_main
    RBRACE
    ;

body_main
    :
    statement
    (scheduling)?
    statement
    ;

varDecName:
    var_dec=IDENTIFIER
    { System.out.print("VarDec:"+$var_dec.text);}
    ;

arrDecName:
    LBRACKET arr_size=INT_VAL RBRACKET arr_dec=IDENTIFIER
    { System.out.print("ArrayDec:" + $arr_dec.text + ":"+ "$arr_size.text");}
    ;

globalVars
    :
    STATIC type (varDecName (ASSIGN expression)?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    ;

sharedVars
    :
    SHARED type (varDecName (ASSIGN expression)?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    ;

varDeclaration
    :
    (type | ORDER | TRADE) (varDecName (ASSIGN {System.out.print("Operator:=");} (expression | order | observe))?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    ;

arrDeclaration :
    comment*
    type (varDecName (ASSIGN {System.out.print("Operator:=");} expression)?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    comment*
    ;

valueAccess :
    IDENTIFIER (LBRACKET valueAccess RBRACKET)
    | INT_VAL
    ;

assignment :
    IDENTIFIER (valueAccess)? ASSIGN expression {System.out.print("Operator:=");}
    SEMICOLON
    ;

expression :
    (LPAR expression RPAR)
    | directValue
//    | expression
//    |
    //TO DO
    ;

directValue :
    STRING_VAL
    | DOUBLE_VAL
    | FLOAT_VAL
    | INT_VAL
    | BOOLEAN_VAL
    | ZERO
    ;

statement :
    arrDeclaration statement
    | varDeclaration statement
    | functionCall { System.out.print("FunctionCall");} statement
    | assignment statement
    | ifStatement statement
    | whileLoop statement
    | forLoop statement
    | print statement
    | trycatch statement
    | //epsilon
    ;

type
    :
    INT | FLOAT | BOOL | DOUBLE | STRING | TRADE
    ;

comment
    :
    (MULTICOMMENT | LINECOMMENT)+
    ;

elseStatement
    :
    ELSE { System.out.print("Conditional:else");} ((LPAR expression RPAR) | expression)
    (LBRACE statement SEMICOLON RBRACE)
    | ifStatement
    ;
ifStatement
    :
    IF { System.out.print("Conditional:if");} ((LPAR expression RPAR) | expression)
    LBRACE statement SEMICOLON RBRACE (elseStatement | /*epsilon*/)
    ;

forLoop
    :
    FOR LPAR (varDeclaration | assignment)? SEMICOLON expression? SEMICOLON expression? RPAR
    LBRACE statement SEMICOLON RBRACE
    ;

whileLoop
    :
    WHILE ((LPAR expression RPAR) | expression)
    LBRACE statement SEMICOLON RBRACE
    ;

oSoIfunction
    :
    VOID (ONSTART | ONINIT) LPAR TRADE IDENTIFIER RPAR (THROW EXCEPTION)?
    LBRACE statement SEMICOLON RBRACE
    ;

function
    :
    (type|VOID)
    name=IDENTIFIER { System.out.println("MethodDec:" + $name.text); }
    LPAR
    type IDENTIFIER
    (COMMA type IDENTIFIER)*
    RPAR
    (THROW EXCEPTION)?
    LBRACE
    body_function
    RBRACE
    ;

body_function
    :
    statement
    ;

print
    :
    PRINT { System.out.println("Built-in:print"); }
    LPAR
    STRING_VAL
    RPAR
    SEMICOLON
    ;


connect
    :
    CONNECT
    LPAR
    STRING_VAL
    COMMA
    STRING_VAL
    RPAR
    SEMICOLON
    ;

observe
    :
    OBSERVE
    LPAR
    STRING_VAL
    RPAR
    SEMICOLON
    ;

refreshrate
    :
    LPAR
    RPAR
    ;

order
    :
    ORDER LPAR (BUY | SELL)
    (DOUBLE_VAL | FLOAT_VAL | INT_VAL)
    (DOUBLE_VAL | FLOAT_VAL | INT_VAL)
    (DOUBLE_VAL | FLOAT_VAL | INT_VAL)
    RPAR
    SEMICOLON
    ;

functionCall
    :
    IDENTIFIER LPAR (expression | TYPE IDENTIFIER)* RPAR SEMICOLON
    ;

trycatch
    :
    TRY
    (LBRACE (statement) RBRACE)
    CATCH
    EXCEPTION IDENTIFIER
    (LBRACE (statement) RBRACE)
    ;

scheduling
    :
    SCHEDULE
    schedulingTerm PREORDER scheduling SEMICOLON | schedulingTerm SEMICOLON
    ;
schedulingTerm
    :
    IDENTIFIER PARALLEL schedulingTerm | LPAR scheduling RPAR PARALLEL schedulingTerm | LPAR scheduling RPAR | IDENTIFIER
    ;




//program : statement+;
// TODO: Complete the parser rules
/*Ex:
statement : VarDeclaration {System.out.println("VarDec:"+...);}
          | ArrayDeclaration ...
          | ...
          ;
*/
