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
BOOLEAN:   'bool';
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


// Other

IDENTIFIER: [a-z][a-zA-Z0-9_]*;
PREDICATE:  [A-Z][a-zA-Z0-9_]*;
ARROW:      '=>';
LINECOMMENT:'//' ~[\r\n]* -> skip;
COMMENT:    '/*' .*? '*/' -> skip;
WS:         [ \t\r\n]+ -> skip;




// TODO: Complete the lexer rules


// Parser rules
program : statement+;
// TODO: Complete the parser rules
/*Ex:
statement : VarDeclaration {System.out.println("VarDec:"+...);}
          | ArrayDeclaration ...
          | ...
          ;
*/
