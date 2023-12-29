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
    (LBRACK INT_LITERAL RBRACK { $varDecRet.setLength($INT_LITERAL.int); })? //TODO : what to do with INT_LITERAL ???
    ID (ASSIGN expression)? SEMICOLON { $varDecRet.setIdentifier($ID.text); $varDecRet.setLine($ID.line); };

functionDeclaration returns [FunctionDeclaration funcDecRet] : { $funcDecRet = new FunctionDeclaration(); }
    primitiveType { $funcDecRet.setReturnType($primitiveType.primitiveTypeRet); }
    ID { $funcDecRet.setName($ID.text); $funcDecRet.setLine($ID.line); }
    LPAREN (allType (LBRACK INT_LITERAL RBRACK)? ID { $funcDecRet.addArg($allType.allTypeRet, $ID.text); }
    (COMMA allType (LBRACK INT_LITERAL RBRACK)? ID { $funcDecRet.addArg($allType.allTypeRet, $ID.text); })*)?
    RPAREN (THROW EXCEPTION)? (LBRACE (statement { $funcDecRet.addStatement($statement.statementRet); })* RBRACE | statement { $funcDecRet.addStatement($statement.statementRet); });

mainDeclaration returns [MainDeclaration mainDecRet]:
    VOID MAIN LPAREN RPAREN
    (LBRACE statement* RBRACE | statement)
    //TODO : must be checked
    {
        $mainDecRet = new MainDeclaration();
        for (Statement stmt : mainBody){
            if (stmt instanceof varDeclaration ){
                if (stmt.getType() instanceof TradeType){
                    $mainDecRet.addActorInstantiation(stmt);
                }
            }
            else{
                $mainDecRet.addStatement(stmt);
            }
        }


    }
    ;


initDeclaration returns [OnInitDeclaration initDecRet]:
    VOID ONINIT LPAREN TRADE tradeName=ID RPAREN
    (THROW EXCEPTION)?
    (LBRACE initBody=statement* RBRACE | initBody=statement)

    {
        $initDecRet = new OnInitDeclaration();
        $initDecRet.setTradeName($tradeName.text);
        for (Statement stmt: initBody){
            $initDecRet.addStatement(stmt.statementRet);
        }
    }
    ;

startDeclaration returns [OnStartDeclaration startDecRet]:
    VOID ONSTART LPAREN TRADE tradeName=ID RPAREN
    (THROW EXCEPTION)?
    (LBRACE startBody=statement* RBRACE | startBody=statement)

    {
        $startDecRet = new OnStartDeclaration();
            $startDecRet.setTradeName($tradeName.text);
            for (Statement stmt: startBody){
                $startDecRet.addStatement(stmt.statementRet);
            }
    }
    ;

assignStatement returns [AssignStmt assignStmtRet]: //TODO : check if is nessery to save (assign) in the AssignStmt class (= , -= , += , )
    ID (LBRACK lval=expression RBRACK)?
    assign
    rval=expression
    SEMICOLON
    {
        $assignStmtRet = new AssignStmt($lval.expressionRet , $rval.expressionRet);
    }
    ;

ifStatement returns [IfElseStmt ifStmtRet] :
    IF LPAREN expression RPAREN
        (LBRACE ifBody=statement* RBRACE | ifBody=statement)
    (ELSE
        (LBRACE elseBody=statement* RBRACE | elseBody=statement)
    )?
    {
        $ifStmtRet= new IfElseStmt($expression.expressionRet);
            for (Statement stmt : ifBody) {
                $ifStmtRet.addThenStatement(stmt.statementRet);
            }
            for (Statement stmt : elseBody) {
                $ifStmtRet.addElseStatement(stmt.statementRet));
            }
    };

whileStatement returns [WhileStmt whileStmtRet]:
    WHILE LPAREN expression RPAREN
        (LBRACE whileBody=statement* RBRACE | whileBody=statement)
    {
        $whileStmtRet = new WhileStmt($expression.expressionRet);
            for (Statement stmt : whileBody){
                $whileStmtRet.addBody(stmt.statementRet);
            }
    };

forStatement returns [ForStmt forStmtRet]: {$forStmtRet = new ForStmt();}
    FOR LPAREN theInit=statement theCondition=expression SEMICOLON theUpdate=expression? RPAREN
        (LBRACE forBody=statement* RBRACE | forBody=statement)
    {
        if (theInit != null){
            for (Statement stmt : theInit){
                $forStmtRet.addInit(stmt.statementRet);
            }
        }

        if (theCondition != null){
            $forStmtRet.setCondition($theCondition.expressionRet);
        }

        if (theUpdate != null){
            for (Statement stmt : theUpdate){
                $forStmtRet.addUpdate(stmt.expressionRet);
            }
        }

        if (forBody != null){
            for (Statement stmt : forBody){
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

        for (Statement stmt : tryBody){
            $tryCatchStmtRet.addThenStatement(stmt.statementRet);
        }
        for (Statement stmt : catchBody){
            $tryCatchStmtRet.addElseStatement(stmt.statementRet);
        }
    };

continueBreakStatement returns [ContinueBreakStmt continueBreakStmtRet]:
    (BREAK { $continueBreakStmtRet = new ContinueBreakStmt($BREAK.text); }
    | CONTINUE { $continueBreakStmtRet = new ContinueBreakStmt($CONTINUE.text); })
     SEMICOLON;
    //TODO : NOT SURE

returnStatement returns[ReturnStmt returnStmtRet]:
    RETURN returnExp=expression SEMICOLON
    {
        $returnStmtRet = new ReturnStmt($returnExp.expressionRet);
    };

throwStatement returns[ThrowStmt throwStmtRet]:
    THROW throwed=expression SEMICOLON
    {
        $throwStmtRet = new ThrowStmt($throwed.expressionRet);
    }
    ;

functionCall returns [FunctionCall funCallRet]:
    (espetialFunction { $funCallRet = new FunctionCall($espetialFunction.espFuncRet)} //TODO : functionCall gets an Identifier but Identifier class is inherited from Expressions ??
    | complexType
    | ID)
     LPAREN (expression (COMMA expression)*)? RPAREN;

methodCall : ID (LBRACK expression RBRACK)? DOT espetialMethod LPAREN (expression (COMMA expression)*)? RPAREN;

expression returns [Expression expressionRet] :
             value { $expressionRet = $value.valueRet }
           | expression DOT espetialVariable { $expressionRet = MethodCall($expression.expressionRet, $espetialVariable.espVarRet); } //TODO : what is espetialVariable name?
           | expression opr=(INC | DEC) { $expressionRet = UnaryExpression($opr, $expression.expressionRet); } //TODO : opr might be broken
           | opr=(NOT | MINUS | BIT_NOT | INC | DEC) expression { $expressionRet = UnaryExpression($opr, $expression.expressionRet); } //TODO : opr might be broken
           | lexpr=expression opr=(MULT | DIV | MOD) rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken
           | lexpr=expression opr=(PLUS | MINUS) rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken //
           | lexpr=expression opr=(L_SHIFT | R_SHIFT) rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken
           | lexpr=expression opr=(LT | GT) rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken
           | lexpr=expression opr=(EQ | NEQ) rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken
           | lexpr=expression opr=(BIT_AND | BIT_OR | BIT_XOR) rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken
           | lexpr=expression AND rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken
           | lexpr=expression OR rexpr=expression { $expressionRet = BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr);} //TODO : opr might be broken
           | ID (LBRACK expression RBRACK)? { $expressionRet = ArrayIdentifier($ID.text, $expression.expressionRet); } //TODO :
           | LPAREN expression RPAREN { $expressionRet = $expression.expressionRet; }
           | functionCall { $expressionRet =  FunctionCall(); } //TODO : functionCall not defined yet
           | methodCall { $expressionRet = MethodCall(); }; //TODO : MethodCall not defined yet

value returns [Value valueRet] :
    INT_LITERAL  { $valueRet = new IntValue($INT_LITERAL.int); }
    | FLOAT_LITERAL { $valueRet = new FloatValue($FLOAT_LITERAL.text.float); } //TODO : correct cast to flaot?
    | STRING_LITERAL { $valueRet = new StringValue($STRING_LITERAL.text); }
    | SELL { $valueRet = new StringValue($SELL.text); } //Might be broken
    | BUY { $valueRet = new StringValue($BUY.text); }; //Might be broken

primitiveType returns [Type primitiveTypeRet]:
    FLOAT { $primitiveTypeRet = new FloatType(); }
    | DOUBLE { $primitiveTypeRet = new DoubleType(); }
    | INT { $primitiveTypeRet = new IntType(); }
    | BOOL { $primitiveTypeRet = new BoolType(); }
    | STRING { $primitiveTypeRet = new StringType(); }
    | VOID { $primitiveTypeRet = new VoidType(); };

complexType returns [Type complexTypeRet]:
    ORDER  { $complexTypeRet = new OrderType(); }
    | TRADE { $complexTypeRet = new TradeType(); }
    | CANDLE { $complexTypeRet = new CandleType(); }
    | EXCEPTION { $complexTypeRet = new ExceptionType(); };

allType returns [Type allTypeRet]:
    primitiveType { $allTypeRet = $primitiveType.primitiveTypeRet; }
    | complexType { $allTypeRet = $complexType.complexTypeRet; };

espetialFunction returns [String espFuncRet]: //TODO : Not sure
    REFRESH_RATE { $espFuncRet = new String($REFRESH_RATE.text); }
    | CONNECT { $espFuncRet = new String($CONNECT.text); }
    | OBSERVE { $espFuncRet = new String($OBSERVE.text); }
    | GET_CANDLE { $espFuncRet = new String($GET_CANDLE.text); }
    | TERMINATE { $espFuncRet = new String($TERMINATE.text); }
    | PRINT { $espFuncRet = new String($PRINT.text); };

espetialVariable returns [String espVarRet]: //TODO : Not sure
    ASK { $espVarRet = new String($ASK.text); }
    | BID { $espVarRet = new String($BID.text); }
    | TIME { $espVarRet = new String($TIME.text); }
    | HIGH { $espVarRet = new String($HIGH.text); }
    | LOW { $espVarRet = new String($LOW.text); }
    | DIGITS { $espVarRet = new String($DIGITS.text); }
    | VOLUME { $espVarRet = new String($VOLUME.text); }
    | TYPE { $espVarRet = new String($TYPE.text); }
    | TEXT { $espVarRet = new String($TEXT.text); }
    | OPEN { $espVarRet = new String($OPEN.text); }
    | CLOSE { $espVarRet = new String($CLOSE.text); };

espetialMethod returns [String espMethRet]: //TODO : Not sure
    OPEN { $espMethRet = new String($OPEN.text); }
    | CLOSE { $espMethRet = new String($CLOSE.text); };

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
