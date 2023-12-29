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
    VOID MAIN LPAREN RPAREN { $mainDecRet = new MainDeclaration(); $mainDecRet.setLine($MAIN.line); }
    (LBRACE (statement {
        if ($statement.statementRet instanceof VarDeclaration){
            if ($statement.statementRet.getType() instanceof TradeType){
                $mainDecRet.addActorInstantiation($statement.statementRet);
            }
        }
        else {
            $mainDecRet.addStatement($statement.statementRet);
        }
    })*
    RBRACE
    |  statement {
        if ($statement.statementRet instanceof VarDeclaration){
            if ($statement.statementRet.getType() instanceof TradeType){
                $mainDecRet.addActorInstantiation($statement.statementRet);
            }
        }
        else {
            $mainDecRet.addStatement($statement.statementRet);
        }
    });
    //TODO : must be checked


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
        $initDecRet.setLine($ONINIT.line);
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
        $startDecRet.setLine($ONSTART.line);
    }
    ;

assignStatement returns [AssignStmt assignStmtRet]: //TODO : check if is nessery to save (assign) in the AssignStmt class (= , -= , += , )
    ID (LBRACK lval=expression RBRACK)?
    assign
    rval=expression
    SEMICOLON
    {
        $assignStmtRet = new AssignStmt($lval.expressionRet , $rval.expressionRet);
        $assignStmtRet.setLine($ID.line);
    }
    ;

ifStatement returns [IfElseStmt ifStmtRet] :
    IF {$ifStmtRet.setLine($IF.line);}
    LPAREN
    expression {$ifStmtRet= new IfElseStmt($expression.expressionRet);}
    RPAREN
        (LBRACE (statement{$ifStmtRet.addThenStatement($statement.statementRet);})* RBRACE
        | statement{$ifStmtRet.addThenStatement($statement.statementRet);})
    (ELSE
        (LBRACE (statement{$ifStmtRet.addElseStatement($statement.statementRet);})* RBRACE
        | statement{$ifStmtRet.addElseStatement($statement.statementRet);})
    )?
    ;

whileStatement returns [WhileStmt whileStmtRet]:
    WHILE {$whileStmtRet.setLine($WHILE.line);}
    LPAREN expression {$whileStmtRet = new WhileStmt($expression.expressionRet);} RPAREN
        (LBRACE (statement{$whileStmtRet.addBody($statement.statementRet);})*
        RBRACE | statement{$whileStmtRet.addBody($statement.statementRet);})
    ;

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

        $forStmtRet.setLine($FOR.line);
    };



tryCatchStatement returns [TryCatchStmt tryCatchStmtRet]:
    TRY { $tryCatchStmtRet = new TryCatchStmt(); $tryCatchStmtRet.setLine($TRY.line); }
        (LBRACE (statement {$tryCatchStmtRet.addThenStatement($statement.statementRet);})*
        RBRACE
        | statement {$tryCatchStmtRet.addThenStatement($statement.statementRet);} )
    (CATCH EXCEPTION ID
        (LBRACE (statement { $tryCatchStmtRet.addElseStatement($statement.statementRet); })*
        RBRACE
        | statement { $tryCatchStmtRet.addElseStatement($statement.statementRet); }))? ;
    //TODO : Construncor TryCatchStmt gets a condition . MUST WRITE

continueBreakStatement returns [ContinueBreakStmt continueBreakStmtRet]:
    (BREAK { $continueBreakStmtRet = new ContinueBreakStmt($BREAK.text); $continueBreakStmtRet.setLine($BREAK.line); }
    | CONTINUE { $continueBreakStmtRet = new ContinueBreakStmt($CONTINUE.text); $continueBreakStmtRet.setLine($CONTINUE.line); })
     SEMICOLON;
    //TODO : NOT SURE

returnStatement returns[ReturnStmt returnStmtRet]:
    RETURN returnExp=expression SEMICOLON
    {
        $returnStmtRet = new ReturnStmt($returnExp.expressionRet);
        $returnStmtRet.setLine($RETURN.line);
    };

throwStatement returns[ThrowStmt throwStmtRet]:
    THROW throwed=expression SEMICOLON
    {
        $throwStmtRet = new ThrowStmt($throwed.expressionRet);
        $throwStmtRet.setLine($THROW.line);
    }
    ;

functionCall returns [FunctionCall funCallRet]:
    (espetialFunction { $funCallRet = new FunctionCall($espetialFunction.espFuncRet); }
    | complexType { $funCallRet = new FunctionCall(Identifier($complexType.complexTypeRet.getName())); }
    | ID { $funCallRet = new FunctionCall(Identifier($ID.text)); })
     LPAREN
     (expression { $funCallRet.addArg($expression.expressionRet); }
     (COMMA expression { $funCallRet.addArg($expression.expressionRet); })*)?
     RPAREN { $funCallRet.setLine($LPAREN.line); }; //TODO : Line might be wrong

methodCall returns [MethodCall methCallRet]:
    //TODO : theInstance Must be checkd
    ID (LBRACK expr=expression RBRACK)? DOT
    espetialMethod LPAREN {
        if(expr != null)
            $methCallRet = new MethodCall(ArrayIdentifier($ID.text , $expression.expressionRet), $espetialMethod.espMethRet);
        else
            $methCallRet = new MethodCall(Identifier($ID.text), $espetialMethod.espMethRet);
        $methCallRet.setLine($ID.line);
    } //TODO : check first arg of MethodCall, Expression() is an empty class just in case
    (expression { $methCallRet.addArg($expression.expressionRet); }
    (COMMA expression { $methCallRet.addArg($expression.expressionRet); })*)?
    RPAREN;

expression returns [Expression expressionRet] :
             value { $expressionRet = $value.valueRet; }
           | expression DOT espetialVariable { $expressionRet = new MethodCall($expression.expressionRet, $espetialVariable.espVarRet); }
           | expression opr=(INC | DEC) { $expressionRet = new UnaryExpression($opr, $expression.expressionRet); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | opr=(NOT | MINUS | BIT_NOT | INC | DEC) expression { $expressionRet = new UnaryExpression($opr, $expression.expressionRet); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | lexpr=expression opr=(MULT | DIV | MOD) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | lexpr=expression opr=(PLUS | MINUS) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken //
           | lexpr=expression opr=(L_SHIFT | R_SHIFT) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | lexpr=expression opr=(LT | GT) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | lexpr=expression opr=(EQ | NEQ) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | lexpr=expression opr=(BIT_AND | BIT_OR | BIT_XOR) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | lexpr=expression AND rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | lexpr=expression OR rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $opr); $expressionRet.setLine($opr.line); } //TODO : opr might be broken
           | ID (LBRACK expr=expression RBRACK)? { if(expr != null) $expressionRet = new ArrayIdentifier($ID.text, $expression.expressionRet); else $expressionRet = new Identifier($ID.text); $expressionRet.setLine($ID.line); }
           | LPAREN expression RPAREN { $expressionRet = $expression.expressionRet; }
           | functionCall { $expressionRet =  $functionCall.funCallRet; }
           | methodCall { $expressionRet = $methodCall.methCallRet; };

value returns [Value valueRet] :
    INT_LITERAL  { $valueRet = new IntValue($INT_LITERAL.int); $valueRet.setLine($INT_LITERAL.line); }
    | FLOAT_LITERAL { $valueRet = new FloatValue($FLOAT_LITERAL.text); $valueRet.setLine($FLOAT_LITERAL.line); } //TODO : correct cast to flaot?
    | STRING_LITERAL { $valueRet = new StringValue($STRING_LITERAL.text); $valueRet.setLine($STRING_LITERAL.line); }
    | SELL { $valueRet = new StringValue($SELL.text); $valueRet.setLine($SELL.line); } //Might be broken
    | BUY { $valueRet = new StringValue($BUY.text); $valueRet.setLine($BUY.line); }; //Might be broken

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

espetialFunction returns [Identifier espFuncRet]: //TODO : Not sure
    REFRESH_RATE { $espFuncRet = new Identifier($REFRESH_RATE.text); }
    | CONNECT { $espFuncRet = new Identifier($CONNECT.text); }
    | OBSERVE { $espFuncRet = new Identifier($OBSERVE.text); }
    | GET_CANDLE { $espFuncRet = new Identifier($GET_CANDLE.text); }
    | TERMINATE { $espFuncRet = new Identifier($TERMINATE.text); }
    | PRINT { $espFuncRet = new Identifier($PRINT.text); };

espetialVariable returns [Identifier espVarRet]: //TODO : Not sure
    ASK { $espVarRet = new Identifier($ASK.text); }
    | BID { $espVarRet = new Identifier($BID.text); }
    | TIME { $espVarRet = new Identifier($TIME.text); }
    | HIGH { $espVarRet = new Identifier($HIGH.text); }
    | LOW { $espVarRet = new Identifier($LOW.text); }
    | DIGITS { $espVarRet = new Identifier($DIGITS.text); }
    | VOLUME { $espVarRet = new Identifier($VOLUME.text); }
    | TYPE { $espVarRet = new Identifier($TYPE.text); }
    | TEXT { $espVarRet = new Identifier($TEXT.text); }
    | OPEN { $espVarRet = new Identifier($OPEN.text); }
    | CLOSE { $espVarRet = new Identifier($CLOSE.text); };

espetialMethod returns [Identifier espMethRet]: //TODO : Not sure
    OPEN { $espMethRet = new Identifier($OPEN.text); }
    | CLOSE { $espMethRet = new Identifier($CLOSE.text); };

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
