grammar UTL;

@header{
    import main.ast.node.*;
    import main.ast.node.declaration.*;
    import main.ast.node.statement.*;
    import main.ast.node.expression.*;
    import main.ast.node.expression.operators.*;
    import main.ast.node.expression.values.*;
    import main.ast.type.primitiveType.*;
    import main.ast.type.complexType.*;
    import main.ast.type.*;
}
// Parser rules
// do not change first rule (program) name
program returns [Program pro] : {$pro = new Program(); $pro.setLine(0);}
    ( varDeclaration { $pro.addVar($varDeclaration.varDecRet); }
    | functionDeclaration { $pro.addFunction($functionDeclaration.funcDecRet); }
    | initDeclaration { $pro.addInit($initDeclaration.initDecRet); }
    | startDeclaration { $pro.addStart($startDeclaration.startDecRet); }
    )* mainDeclaration { $pro.setMain($mainDeclaration.mainDecRet); }
    ;


statement returns [Statement statementRet] :
          ( varDeclaration { $statementRet = $varDeclaration.varDecRet; }
          | functionDeclaration { $statementRet = $functionDeclaration.funcDecRet; }
          | assignStatement { $statementRet = $assignStatement.assignStmtRet; }
          | continueBreakStatement { $statementRet = $continueBreakStatement.continueBreakStmtRet; }
          | returnStatement { $statementRet = $returnStatement.returnStmtRet; }
          | ifStatement { $statementRet = $ifStatement.ifStmtRet; }
          | whileStatement { $statementRet = $whileStatement.whileStmtRet; }
          | forStatement { $statementRet = $forStatement.forStmtRet; }
          | tryCatchStatement { $statementRet = $tryCatchStatement.tryCatchStmtRet; }
          | throwStatement { $statementRet = $throwStatement.throwStmtRet; }
          | expression SEMICOLON { $statementRet = $expression.expressionRet; }
          );

varDeclaration returns [VarDeclaration varDecRet] : { $varDecRet = new VarDeclaration(); }
    allType { $varDecRet.setType($allType.allTypeRet); }
    (LBRACK INT_LITERAL RBRACK { $varDecRet.setLength($INT_LITERAL.intLiteralRet); })?
    ID (ASSIGN expression)? SEMICOLON { $varDecRet.setName($ID.text); $varDecRet.setLine($ID.line); };

functionDeclaration returns [FunctionDeclaration funcDecRet] : { $funcDecRet = new FunctionDeclaration(); }
    primitiveType { $funcDecRet.setReturnType($primitiveType.primitiveTypeRet); }
    ID { $funcDecRet.setName($ID.text); $funcDecRet.setLine($ID.line); }
    LPAREN (allType (LBRACK INT_LITERAL RBRACK)? ID { $funcDecRet.addArg($allType.allTypeRet, $ID.text); }
    (COMMA allType (LBRACK INT_LITERAL RBRACK)? ID { $funcDecRet.addArg($allType.allTypeRet, $ID.text); })*)?
    RPAREN (THROW EXCEPTION)? (LBRACE (statement { $funDecRet.addStatement($statement.statementRet); })* RBRACE | statement { $funDecRet.addStatement($statement.statementRet); });

mainDeclaration : VOID MAIN LPAREN RPAREN (LBRACE statement* RBRACE | statement);

initDeclaration returns [OnInitDeclaration initDecRet]:
    VOID ONINIT LPAREN TRADE tradeName=ID RPAREN
    (THROW EXCEPTION)?
    (LBRACE initBody=statement* RBRACE | initBody=statement)

    {
    $initDecRet = new OnInitDeclaration();
    $initDecRet.setTradeName($tradeName.text);
    for (Statement stmt: $initBody){
        $initDecRet.addStatement(stmt.statementRet);
    }
    }
    ;

startDeclaration : VOID ONSTART LPAREN TRADE ID RPAREN (THROW EXCEPTION)? (LBRACE statement* RBRACE | statement);

assignStatement returns [AssignStmt assignStmtRet]:
    ID (LBRACK lval=expression RBRACK)?
    assign
    rval=expression
    SEMICOLON
    {
        $assignStmtRet = new AssignStmt($lval.exprRet , $rval.exprRet);
    }
    ;

ifStatement returns [IfElseStmt ifStmtRet] :
    IF LPAREN expression RPAREN
        (LBRACE ifBody=statement* RBRACE | ifBody=statement)
    (ELSE
        (LBRACE elseBody=statement* RBRACE | elseBody=statement)
    )?
    {
        $ifStmtRet= new IfElseStmt($expression.exprRet);
            for (Statement stmt : $ifBody) {
                $ifStmtRet.addThenStatement(stmt.statementRet);
            }
            for (Statement stmt : $elseBody) {
                $ifStmtRet.addElseStatement(stmt.statementRet));
            }
    };

whileStatement returns [WhileStmt whileStmtRet]:
    WHILE LPAREN expression RPAREN
        (LBRACE whileBody=statement* RBRACE | whileBody=statement)
    {
        $whileStmtRet = new WhileStmt($expression.exprRet);
            for (Statement stmt : $whileBody){
                $whileStmtRet.addBody(stmt.statementRet);
            }
    };

forStatement returns [ForStmt forStmtRet]: {$forStmtRet = new ForStmt();}
    FOR LPAREN theInit=statement theCondition=expression SEMICOLON theUpdate=expression? RPAREN
        (LBRACE forBody=statement* RBRACE | forBody=statement)
    {
        if ($theInit != null){
            for (Statement stmt : $theInit){
                $forStmtRet.addInit(stmt.statementRet);
            }
        }

        if ($theCondition != null){
            $forStmtRet.setCondition($theCondition.exprRet);
        }

        if ($theUpdate != null){
            for (Statement stmt : $theUpdate){
                $forStmtRet.addUpdate(stmt.exprRet);
            }
        }

        if ($forBody != null){
            for (Statement stmt : $forBody){
                $forStmtRet.addBody(stmt.statementRet);
            }
        }

    };



tryCatchStatement returns [TryCatchStmt tryCatchStmtRet]:
    TRY
        (LBRACE tryBody=statement* RBRACE | tryBody=statement)
    (CATCH EXCEPTION ID
        (LBRACE catchBody=statement* RBRACE | catchBody=statement))?
    //TODO : Construncor TryCatchStmt gets a condition . MUST WRITE
    {
        $tryCatchStmtRet = new TryCatchStmt();

        for (Statement stmt : $tryBody){
            $tryCatchStmtRet.addThenStatement(stmt.statementRet);
        }
        for (Statement stmt : $catchBody){
            $tryCatchStmtRet.addElseStatement(stmt.statementRet);
        }
    };

continueBreakStatement :
    (BREAK | CONTINUE) SEMICOLON;
    //TODO : What is the string token in their constructor

returnStatement returns[ReturnStmt returnStmtRet]:
    RETURN returnExp=expression SEMICOLON
    {
        $returnStmtRet = new ReturnStmt($returnExp.exprRet);
    };

throwStatement returns[ThrowStmt throwStmtRet]:
    THROW throwed=expression SEMICOLON
    {
        $throwStmtRet = new ThrowStmt($throwed.exprRet);
    }
    ;

functionCall : (espetialFunction | complexType | ID) LPAREN (expression (COMMA expression)*)? RPAREN;

methodCall : ID (LBRACK expression RBRACK)? DOT espetialMethod LPAREN (expression (COMMA expression)*)? RPAREN;

expression returns [Expression exprRet] :
             value { $exprRet = $value.val }
           | expression DOT espetialVariable { $exprRet = MethodCall($expression.exprRet, ); } //TODO : what is espetialVariable name?
           | expression opr=(INC | DEC) { $exprRet = UnaryExpression($opr, $expression.exprRet); } //TODO : opr might be broken
           | opr=(NOT | MINUS | BIT_NOT | INC | DEC) expression { $exprRet = UnaryExpression($opr, $expression.exprRet); } //TODO : opr might be broken
           | lexpr=expression opr=(MULT | DIV | MOD) rexpr=expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken
           | expression opr=(PLUS | MINUS) expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken //
           | expression opr=(L_SHIFT | R_SHIFT) expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken
           | expression opr=(LT | GT) expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken
           | expression opr=(EQ | NEQ) expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken
           | expression opr=(BIT_AND | BIT_OR | BIT_XOR) expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken
           | expression AND expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken
           | expression OR expression { $exprRet = BinaryExpression($lexpr.exprRet, $rexpr.exprRet, $opr);} //TODO : opr might be broken
           | ID (LBRACK expression RBRACK)? { $exprRet = ArrayIdentifier($ID.text, $expression.exprRet); } //TODO :
           | LPAREN expression RPAREN { $exprRet = $expression.exprRet; }
           | functionCall { $exprRet =  FunctionCall(); } //TODO : functionCall not defined yet
           | methodCall { $exprRet = MethodCall(); }; //TODO : MethodCall not defined yet

value returns [Value val] :
    INT_LITERAL  { $val = new IntValue($INT_LITERAL.text) }
    | FLOAT_LITERAL { $val = new FloatValue($FLOAT_LITERAL.text) }
    | STRING_LITERAL { $val = new StringValue($STRING_LITERAL.text) }
    | SELL { $val = new StringValue($SELL.text) } //Might be broken
    | BUY { $val = new StringValue($BUY.text) }; //Might be broken

primitiveType : FLOAT | DOUBLE | INT | BOOL | STRING | VOID;

complexType: ORDER | TRADE | CANDLE | EXCEPTION;

allType: primitiveType | complexType;

espetialFunction: REFRESH_RATE | CONNECT | OBSERVE | GET_CANDLE | TERMINATE | PRINT;

espetialVariable: ASK | BID | TIME | HIGH | LOW | DIGITS | VOLUME | TYPE | TEXT | OPEN | CLOSE;

espetialMethod: OPEN | CLOSE;

assign: ASSIGN | ADD_ASSIGN | SUB_ASSIGN | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN;

// Lexer rules
SPACES : [ \t\r\n]+ -> skip;
SEMICOLON : ';';
COMMA : ',';
COLON : ':';
DOT: '.';
LPAREN : '(';
RPAREN : ')';
LBRACE : '{';
RBRACE : '}';
LBRACK : '[';
RBRACK : ']';

PLUS : '+';
MINUS : '-';
MULT : '*';
DIV : '/';
MOD : '%';

AND : '&&';
OR: '||';
NOT: '!';

BIT_AND : '&';
BIT_OR : '|';
BIT_XOR : '^';
L_SHIFT : '<<';
R_SHIFT : '>>';
BIT_NOT : '~';

LT : '<';
GT : '>';
EQ : '==';
NEQ : '!=';

INC : '++';
DEC : '--';

ASSIGN : '=';
ADD_ASSIGN: '+=';
SUB_ASSIGN: '-=';
MUL_ASSIGN: '*=';
DIV_ASSIGN: '/=';
MOD_ASSIGN: '%=';

TRY : 'try';
THROW : 'throw';
CATCH : 'catch';
IF : 'if';
ELSE : 'else';
FOR: 'for';
WHILE : 'while';
BREAK : 'break';
CONTINUE : 'continue';
RETURN : 'return';

MAIN : 'Main';
ONINIT : 'OnInit';
ONSTART : 'OnStart';

FLOAT : 'float';
DOUBLE : 'double';
STRING: 'string';
BOOL: 'bool';
VOID: 'void';
INT : 'int';

BUY : 'BUY';
SELL : 'SELL';

ASK : 'Ask';
BID : 'Bid';
TIME : 'Time';
HIGH : 'High';
LOW : 'Low';
DIGITS : 'Digits';
VOLUME : 'Volume';
TYPE: 'Type';
TEXT: 'Text';
OPEN : 'Open';
CLOSE : 'Close';

TRADE: 'Trade';
ORDER: 'Order';
CANDLE: 'Candle';
EXCEPTION: 'Exception';

REFRESH_RATE : 'RefreshRate';
GET_CANDLE : 'GetCandle';
TERMINATE : 'Terminate';
CONNECT : 'Connect';
OBSERVE : 'Observe';
PRINT : 'Print';

ID : [a-zA-Z_][a-zA-Z_0-9]*;

INT_LITERAL : [1-9][0-9]* | '0';
FLOAT_LITERAL : [0-9]* '.' [0-9]+;
STRING_LITERAL : '"' (~["])* '"';

COMMENT: (('//' ~('\r'|'\n')*) | ('/*' .*? '*/')) -> skip;
