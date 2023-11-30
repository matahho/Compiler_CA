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
//REFRESHRATE:'RefreshRate';
//TERMINATE:  'Terminate';
//CONNECT:    'Connect';
//OBSERVE:    'Observe';
PRINT:      'Print';
//GETCANDLE:  'GetCandle';


//Special Method Function
//CLOSE_METHOD : 'close()';
//OPEN_METHOD : 'open()';


// TIMING
SCHEDULE:   '@schedule';
PREORDER:   'preorder';
PARALLEL:   'parallel';

// Special Valriabels
//TYPE:      'Type';
//ASK:       'Ask';
//BID:       'Bid';
SELL:      'SELL';
BUY:       'BUY';
//VOLUME:    'Volume' ;
//LOW:       'Low';
//HIGH:      'High';
//CLOSE:     'Close';
//OPEN:      'Open';
//TIME:      'Time';

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
    STATIC type (varDecName (ASSIGN {System.out.println("Operator:=");} expression)?) (COMMA (varDecName (ASSIGN {System.out.println("Operator:=");} expression)?))* SEMICOLON
    ;

sharedVars
    :
    SHARED type (varDecName (ASSIGN {System.out.println("Operator:=");} expression)?) (COMMA (varDecName (ASSIGN {System.out.println("Operator:=");} expression)?))* SEMICOLON
    ;

varDeclaration
    :
    (type) varDecName (ASSIGN (expression | orderConstructor | exceptionConstructor /*| observe*/ ){System.out.println("Operator:=");})?
    (COMMA (varDecName (ASSIGN (expression | orderConstructor | exceptionConstructor /*| observe*/ ){System.out.println("Operator:=");})?))*
    SEMICOLON
    ;

arrDeclaration :
    type (arrDecName (ASSIGN {System.out.println("Operator:=");} expression)?) (COMMA (arrDecName (ASSIGN {System.out.println("Operator:=");} expression)?))* SEMICOLON
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
    logicalOrExpression ASSIGN { System.out.println("Operator:=");}assignExpression
    | logicalOrExpression
    ;

logicalOrExpression:
    logicalAndExpression (OR logicalAndExpression { System.out.println("Operator:||");})*
    ;

logicalAndExpression:
    logicalBitExpression (AND logicalBitExpression { System.out.println("Operator:&&");} )*
    ;

logicalBitExpression:
    equalExpression ((ANDBITWISE) equalExpression { System.out.println("Operator:&");}
    | (ORBITWISE) equalExpression { System.out.println("Operator:|");}
    | (XOR) equalExpression { System.out.println("Operator:^");})*
    ;

equalExpression:
    comparisonExpression ((EQL) comparisonExpression { System.out.println("Operator:==");}
    | (NEQ) comparisonExpression { System.out.println("Operator:!=");})*
    ;

comparisonExpression:
    shiftExpression ((GTR) shiftExpression { System.out.println("Operator:>");}
    | (LES) shiftExpression { System.out.println("Operator:<");})*
    ;

shiftExpression:
    plusMinusExpression ((RSHIFT) plusMinusExpression { System.out.println("Operator:>>");}
    | (LSHIFT) plusMinusExpression { System.out.println("Operator:<<");})*
    ;

plusMinusExpression:
    multiplyDivideExpression ((PLUS) multiplyDivideExpression {System.out.println("Operator:+");}
    | (MINUS) multiplyDivideExpression { System.out.println("Operator:-");})*
    ;

multiplyDivideExpression:
    unaryExpression ((MULT) unaryExpression { System.out.println("Operator:*");}
    | (DIV) unaryExpression { System.out.println("Operator:/");})*
    ;

unaryExpression:
    ((MINUS) unaryPostExpression { System.out.println("Operator:-");}
    | (NOTBITWISE) unaryPostExpression { System.out.println("Operator:~");}
    | (NOT) unaryPostExpression { System.out.println("Operator:!");}
    | (PLUSPLUS) unaryPostExpression { System.out.println("Operator:++");}
    | (MINUSMINUS) unaryPostExpression { System.out.println("Operator:--");})+
    | retrieveListExpression
    ;

unaryPostExpression :
    retrieveListExpression ((MINUSMINUS) retrieveListExpression {System.out.println("Operator:--");}
    | (PLUSPLUS) retrieveListExpression { System.out.println("Operator:++");})*
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
    | function statement
    | functionCall { System.out.println("FunctionCall");} SEMICOLON statement
    | assignment statement
    | ifStatement statement
    | whileLoop statement
    | forLoop statement
    | print statement
    | trycatch statement
//    | refreshrate statement
//    | connect statement
    | throwStatement statement
    | returnStatemnet statement
    | //epsilon
    ;

type
    :
    INT | FLOAT | BOOL | DOUBLE | STRING | TRADE | ORDER | EXCEPTION | CANDLE
    ;

comment
    :
    (MULTICOMMENT | LINECOMMENT)+
    ;

elseStatement
    :
    (ELSE { System.out.println("Conditional:else");}
    (LBRACE statement RBRACE))
    | ifStatement
    ;

ifStatement
    :
    IF { System.out.println("Conditional:if");} (LPAR expression RPAR)
    LBRACE statement RBRACE (elseStatement)?
    ;

forLoop
    :
    FOR { System.out.println("Loop:for");}
    LPAR (varDeclaration | assignment)? SEMICOLON expression? SEMICOLON expression? RPAR
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
    WHILE { System.out.println("Loop:while ");}
    ((LPAR expression RPAR) | expression)
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
    (type IDENTIFIER (COMMA type IDENTIFIER)*)*
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

returnStatemnet
    :
    RETURN (expression | directValue) SEMICOLON
    ;


print
    :
    PRINT { System.out.println("Built-in:print"); }
    LPAR
    (
    STRING_VAL |
    functionCall
    )
    RPAR
    SEMICOLON
    ;

//
//connect
//    :
//    CONNECT
//    LPAR
//    STRING_VAL
//    COMMA
//    STRING_VAL
//    RPAR
//    SEMICOLON
//    ;
//
//observe
//    :
//    OBSERVE
//    LPAR
//    STRING_VAL
//    RPAR
//    ;
//
//refreshrate
//    :
//    REFRESHRATE
//    LPAR
//    RPAR
//    SEMICOLON
//    ;

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
    IDENTIFIER
    LPAR
    (expression | functionCall)?
    (COMMA(expression | functionCall))*
    RPAR
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
    (typeNumber=INT_VAL{ System.out.println("ErrorControl:" + $typeNumber.text); }
     | IDENTIFIER)
    COMMA
    (STRING_VAL | IDENTIFIER)
    RPAR
    ;


throwStatement
    :
    THROW
    (exceptionConstructor| IDENTIFIER)
    SEMICOLON
    ;

scheduling
    :
    (schedulingTerm PREORDER scheduling )| (schedulingTerm)
    ;
schedulingTerm
    :
    (IDENTIFIER PARALLEL IDENTIFIER )|(LPAR scheduling RPAR PARALLEL scheduling)|(LPAR scheduling RPAR)|(IDENTIFIER)
    ;


//
//candleVarsAccess
//    :
//    (valueAccess)
//    DOT
//    (TIME | OPEN | CLOSE | HIGH | LOW | VOLUME)
//
//    ;




//program : statement+;
// TODO: Complete the parser rules
/*Ex:
statement : VarDeclaration {System.out.println("VarDec:"+...);}
          | ArrayDeclaration ...
          | ...
          ;
*/
