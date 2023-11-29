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
PRINT:      'print';
GETCANDLE:  'GetCandle';


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




// TODO: Complete the lexer rules


// Parser rules
UTL
    :
    (globalVars | sharedVars)* (function )* main (comment)*
    ;



main
    :
    (type | VOID)
    MAIN
    LPAR (statement) RPAR LBRACE
    body_function
    RBRACE
    ;


varDecName:
    var_dec=IDENTIFIER
    { System.out.print("VarDec:"+$var_dec.text+"\n");}
    ;

arrDecName:
    LBRACKET arr_size=INT_VAL RBRACKET arr_dec=IDENTIFIER
    { System.out.print("ArrayDec:" + $arr_dec.text + ":"+ "$arr_size.text" + "\n");}
    ;

globalVars
    :
    STATIC type (varDecName (ASSIGN expression)?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    ;

sharedVars
    :
    comment*
    SHARED type (varDecName (ASSIGN expression)?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    comment*
    ;


varDeclaration:
    comment*
    type (varDecName (ASSIGN expression)?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    comment*
    ;

arrDeclaration :
    comment*
    type (varDecName (ASSIGN expression)?) (COMMA (varDecName (ASSIGN expression)?))* SEMICOLON
    comment*
    ;

valueAccess :
    IDENTIFIER (LBRACKET valueAccess RBRACKET)
    | INT_VAL
    ;

assignment :
    IDENTIFIER (valueAccess)? ASSIGN expression {System.out.print("Operator:=\n";}
    SEMICOLON
    ;

expression :
    LPAR expression RPAR
    //TO DO
    ;


statement :
    //TO DO
    ;

type
    :
    INT | FLOAT | BOOLEAN | DOUBLE | STRING
    ;

comment
    :
    (MULTICOMMENT | LINECOMMENT)+
    ;

elseStatement :
    ELSE { System.out.print("Conditional:else\n");} (((LPAR expression RPAR) | expression)
    ((LBRACE (statement SEMICOLON)+ RBRACE) | statement SEMICOLON ))
    | ifStatement
    ;
ifStatement
    :
    IF { System.out.print("Conditional:if\n");} ((LPAR expression RPAR) | expression)
    ((LBRACE (statement SEMICOLON)+ RBRACE) | statement SEMICOLON ) (elseStatement | /*epsilon*/)
    ;

forLoop
    :
    FOR LPAR (varDeclaration | assignment)? SEMICOLON expression? SEMICOLON expression? RPAR
    ((LBRACE statement SEMICOLON RBRACE) | statement SEMICOLON)
    ;

whileLoop
    :
    WHILE ((LPAR expression RPAR) | expression)
    ((LBRACE statement SEMICOLON RBRACE) | statement SEMICOLON)
    ;

function
    :
    (type|VOID)
    name=IDENTIFIER { System.out.println("MethodDec:"$name.text\n); }
    LPAR (statement) RPAR
    LBRACE
    body_funtion
    RBRACE
    ;

body_function
    :
    (statement | COMMENT)*
    ;


print
    :
    PRINT { System.out.println("Built-in:print"\n); }
    LPAR
    STRING_VAL
    RPAR
    SEMICOLON
    ;







//program : statement+;
// TODO: Complete the parser rules
/*Ex:
statement : VarDeclaration {System.out.println("VarDec:"+...);}
          | ArrayDeclaration ...
          | ...
          ;
*/
