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
PREORDER:   'preorder';
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
STRING_VAL:  DOUBLEQUOTE [a-zA-Z0-9_]* DOUBLEQUOTE;

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
    (SCHEDULE{System.out.println("ConcurrencyControl:Schedule");} scheduling SEMICOLON)?
    statement
    ;

varDecName:
    var_dec=IDENTIFIER
    { System.out.println("VarDec:"+$var_dec.text);}
    ;

arrDecName:
    LBRACKET arr_size=INT_VAL RBRACKET arr_dec=IDENTIFIER
    { System.out.println("ArrayDec:" + $arr_dec.text + ":"+ "$arr_size.text");}
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
    (type) varDecName (ASSIGN {System.out.println("Operator:=");} (expression | orderConstructor | exceptionConstructor | observe))?
    (COMMA (varDecName (ASSIGN {System.out.println("Operator:=");}(expression | orderConstructor | exceptionConstructor | observe))?))*
    SEMICOLON
    ;

arrDeclaration :
    type (arrDecName (ASSIGN {System.out.println("Operator:=");} expression)?) (COMMA (arrDecName (ASSIGN expression)?))* SEMICOLON
    ;

valueAccess :
    IDENTIFIER (LBRACKET valueAccess RBRACKET)
    | INT_VAL
    ;

assignment :
    IDENTIFIER (valueAccess)? ASSIGN expression {System.out.println("Operator:=");}
    SEMICOLON
    ;

expression:
    assignExpression
    ;

assignExpression:
    logicalOrExpression ASSIGN { System.out.println("Operator:=\n");}assignExpression
    | logicalOrExpression
    ;

logicalOrExpression:
    logicalAndExpression (OR logicalAndExpression { System.out.println("Operator : ||\n");})*
    ;

logicalAndExpression:
    logicalBitExpression (AND logicalBitExpression { System.out.println("Operator : &&\n");} )*
    ;

logicalBitExpression:
    equalExpression ((ANDBITWISE) equalExpression { System.out.println("Operator : &\n");}
    | (ORBITWISE) equalExpression { System.out.println("Operator : |\n");}
    | (XOR) equalExpression { System.out.println("Operator : ^\n");})*
    ;

equalExpression:
    comparisonExpression ((EQL) comparisonExpression { System.out.println("Operator : ==\n");}
    | (NEQ) comparisonExpression { System.out.println("Operator:!=\n");})*
    ;

comparisonExpression:
    shiftExpression ((GTR) shiftExpression { System.out.println("Operator : >\n");}
    | (LES) shiftExpression { System.out.println("Operator:<\n");})*
    ;

shiftExpression:
    plusMinusExpression ((RSHIFT) plusMinusExpression { System.out.println("Operator : >>\n");}
    | (LSHIFT) plusMinusExpression { System.out.println("Operator : <<\n");})*
    ;

plusMinusExpression:
    multiplyDivideExpression ((PLUS) multiplyDivideExpression {System.out.println("Operator : +\n");}
    | (MINUS) multiplyDivideExpression { System.out.println("Operator : -\n");})*
    ;

multiplyDivideExpression:
    unaryExpression ((MULT) unaryExpression { System.out.println("Operator : *\n");}
    | (DIV) unaryExpression { System.out.println("Operator : /\n");})*
    ;

unaryExpression:
    ((MINUS) unaryPostExpression { System.out.println("Operator : -\n");}
    | (NOTBITWISE) unaryPostExpression { System.out.println("Operator : ~\n");}
    | (NOT) unaryPostExpression { System.out.println("Operator : !\n");}
    | (PLUSPLUS) unaryPostExpression { System.out.println("Operator : ++\n");}
    | (MINUSMINUS) unaryPostExpression { System.out.println("Operator : --\n");})+
    | retrieveListExpression
    ;

unaryPostExpression :
    retrieveListExpression ((MINUSMINUS) retrieveListExpression {System.out.println("Operator : --\n");}
    | (PLUSPLUS) retrieveListExpression { System.out.println("Operator : ++\n");})*
    ;

retrieveListExpression:
    (accessMemberExpression
    (LBRACKET expression RBRACKET)*) (DOT retrieveListExpression)*
    ;

accessMemberExpression:
    parantheseExpression
    (DOT IDENTIFIER)*
    ;

parantheseExpression:
    (directValue (LPAR callArgs RPAR)* )
    | LPAR expression? RPAR
    ;

callArgs:
    (expression (COMMA expression)*)?
    ;

directValue :
    STRING_VAL
    | DOUBLE_VAL
    | FLOAT_VAL
    | INT_VAL
    | BOOLEAN_VAL
    | ZERO
    | orderConstructor
    | exceptionConstructor
    | IDENTIFIER
    ;

statement :
    arrDeclaration statement
    | varDeclaration statement
    | functionCall { System.out.println("FunctionCall");} statement
    | assignment statement
    | ifStatement statement
    | whileLoop statement
    | forLoop statement
    | print statement
    | trycatch statement
    | refreshrate statement
    | //epsilon
    ;

type
    :
    INT | FLOAT | BOOL | DOUBLE | STRING | TRADE | ORDER | EXCEPTION
    ;

comment
    :
    (MULTICOMMENT | LINECOMMENT)+
    ;

elseStatement
    :
    ELSE { System.out.println("Conditional:else");} (LPAR expression RPAR)
    (LBRACE statement RBRACE)
    | ifStatement
    ;
ifStatement
    :
    IF { System.out.println("Conditional:if");} (LPAR expression RPAR)
    LBRACE statement RBRACE (elseStatement | /*epsilon*/)
    ;

forLoop
    :
    FOR LPAR (varDeclaration | assignment)? SEMICOLON expression? SEMICOLON expression? RPAR
    LBRACE forLoopBody RBRACE
    ;

forLoopBody
    :
    statement
    (BREAK SEMICOLON forLoopBody
    | CONTINUE SEMICOLON forLoopBody
    | /*epsilon*/
    )
    ;

whileLoop
    :
    WHILE ((LPAR expression RPAR) | expression)
    LBRACE whileLoopBody SEMICOLON RBRACE
    ;

whileLoopBody
    :
    statement
    (BREAK SEMICOLON whileLoopBody
    | CONTINUE SEMICOLON whileLoopBody
    | /*epsilon*/
    )
    ;


oSoIfunction
    :
    VOID (ONSTART | ONINIT) LPAR TRADE IDENTIFIER RPAR (THROW EXCEPTION)?
    LBRACE statement RBRACE
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
    SEMICOLON
    ;

orderConstructor
    :
    ORDER LPAR (BUY | SELL) COMMA
    (DOUBLE_VAL | FLOAT_VAL | INT_VAL) COMMA
    (DOUBLE_VAL | FLOAT_VAL | INT_VAL) COMMA
    (DOUBLE_VAL | FLOAT_VAL | INT_VAL)
    RPAR
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

exceptionConstructor
    :
    EXCEPTION
    LPAR
    (INT_VAL | IDENTIFIER)
    COMMA
    (STRING_VAL | IDENTIFIER)
    RPAR
    ;

scheduling
    :
    (schedulingTerm PREORDER scheduling )| (schedulingTerm)
    ;
schedulingTerm
    :
    (IDENTIFIER PARALLEL IDENTIFIER )|(LPAR scheduling RPAR PARALLEL scheduling)|(LPAR scheduling RPAR)|(IDENTIFIER)
    ;





//program : statement+;
// TODO: Complete the parser rules
/*Ex:
statement : VarDeclaration {System.out.println("VarDec:"+...);}
          | ArrayDeclaration ...
          | ...
          ;
*/
