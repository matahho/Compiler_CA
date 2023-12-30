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
          | expression { $statementRet = new ExpressionStmt($expression.expressionRet); }
          SEMICOLON);

varDeclaration returns [VarDeclaration varDecRet] : { $varDecRet = new VarDeclaration(); }
    allType { $varDecRet.setType($allType.allTypeRet); }
    (LBRACK INT_LITERAL RBRACK { $varDecRet.setLength($INT_LITERAL.int); })?
    ID (ASSIGN expression)? SEMICOLON { $varDecRet.setIdentifier(new Identifier($ID.text)); $varDecRet.setLine($ID.line); };

functionDeclaration returns [FunctionDeclaration funcDecRet] : { $funcDecRet = new FunctionDeclaration(); }
    primitiveType { $funcDecRet.setReturnType($primitiveType.primitiveTypeRet); }
    ID { $funcDecRet.setName(new Identifier($ID.text)); $funcDecRet.setLine($ID.line); }
    LPAREN { VarDeclaration temp = new VarDeclaration(); }
    (allType { temp.setType($allType.allTypeRet); }
    (LBRACK INT_LITERAL RBRACK { temp.setLength($INT_LITERAL.int); })?
    ID {
        temp.setIdentifier(new Identifier($ID.text));
        $funcDecRet.addArg(temp);
    }
    (COMMA allType {temp.setType($allType.allTypeRet);}
    (LBRACK INT_LITERAL RBRACK {temp.setLength($INT_LITERAL.int);})?
    ID {
        temp.setIdentifier(new Identifier($ID.text));
        $funcDecRet.addArg(temp);
    })*)?
    RPAREN (THROW EXCEPTION)? (LBRACE (statement { $funcDecRet.addStatement($statement.statementRet); })* RBRACE | statement { $funcDecRet.addStatement($statement.statementRet); });

mainDeclaration returns [MainDeclaration mainDecRet]:
    VOID MAIN LPAREN RPAREN { $mainDecRet = new MainDeclaration(); $mainDecRet.setLine($MAIN.line); }
    (LBRACE (statement {
        if ($statement.statementRet instanceof VarDeclaration){
            if ($statement.statementRet.getType() instanceof TradeType){
                $mainDecRet.addActorInstantiation( (VarDeclaration)$statement.statementRet );
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
                $mainDecRet.addActorInstantiation( (VarDeclaration)$statement.statementRet );
            }
        }
        else {
            $mainDecRet.addStatement($statement.statementRet);
        }
    });
    //TODO : must be checked


initDeclaration returns [OnInitDeclaration initDecRet]:
    VOID
    ONINIT {$initDecRet = new OnInitDeclaration(); $initDecRet.setLine($ONINIT.line);}
    LPAREN TRADE ID { $initDecRet.setTradeName(new Identifier($ID.text)); }RPAREN
    (THROW EXCEPTION)?
    (LBRACE (statement{$initDecRet.addStatement($statement.statementRet);})* RBRACE
    | statement{$initDecRet.addStatement($statement.statementRet);});

startDeclaration returns [OnStartDeclaration startDecRet]:
    VOID
    ONSTART { $startDecRet = new OnStartDeclaration(); $startDecRet.setLine($ONSTART.line);}
    LPAREN TRADE ID {$startDecRet.setTradeName(new Identifier($ID.text));}RPAREN
    (THROW EXCEPTION)?
    (LBRACE (statement {$startDecRet.addStatement($statement.statementRet);})* RBRACE
    | statement {$startDecRet.addStatement($statement.statementRet);});

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
    FOR {$forStmtRet.setLine($FOR.line);}
    LPAREN theInit=statement theCondition=expression SEMICOLON theUpdate=expression? RPAREN
        (LBRACE
        (statement{$forStmtRet.addBody($statement.statementRet);})*
        RBRACE
        | statement{ $forStmtRet.addBody($statement.statementRet); })
    {
        if ($theInit.statementRet != null){
            $forStmtRet.addInit($theInit.statementRet);

        }

        if ($theCondition.expressionRet != null){
            $forStmtRet.setCondition($theCondition.expressionRet);
        }

        if ($theUpdate.expressionRet != null){
            Statement temp = new ExpressionStmt($theUpdate.expressionRet);
            $forStmtRet.addUpdate(temp);
        }

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
    //TODO : Construncor TryCatchStmt gets a condition . MUST WRITE (Mahdi : I have added a new construnctor to TryCatchStmt)

continueBreakStatement returns [ContinueBreakStmt continueBreakStmtRet]:
    (BREAK { $continueBreakStmtRet = new ContinueBreakStmt($BREAK.text); $continueBreakStmtRet.setLine($BREAK.line); }
    | CONTINUE { $continueBreakStmtRet = new ContinueBreakStmt($CONTINUE.text); $continueBreakStmtRet.setLine($CONTINUE.line); })
     SEMICOLON;

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
    | complexType { $funCallRet = new FunctionCall(new Identifier($complexType.complexTypeRet.getName())); }
    | ID { $funCallRet = new FunctionCall(new Identifier($ID.text)); })
     LPAREN
     (expression { $funCallRet.addArg($expression.expressionRet); }
     (COMMA expression { $funCallRet.addArg($expression.expressionRet); })*)?
     RPAREN { $funCallRet.setLine($LPAREN.line); };

methodCall returns [MethodCall methCallRet]:
    ID {boolean temp = false;}(LBRACK expression RBRACK {temp = true;})? DOT
    espetialMethod LPAREN {
        if(temp)
            $methCallRet = new MethodCall(new ArrayIdentifier($ID.text , $expression.expressionRet), $espetialMethod.espMethRet);
        else
            $methCallRet = new MethodCall(new Identifier($ID.text), $espetialMethod.espMethRet);
        $methCallRet.setLine($ID.line);
    }
    (expression { $methCallRet.addArg($expression.expressionRet); }
    (COMMA expression { $methCallRet.addArg($expression.expressionRet); })*)?
    RPAREN;

expression returns [Expression expressionRet] locals [UnaryOperator op1, BinaryOperator op2, int Line] :
             value { $expressionRet = $value.valueRet; }
           | expression DOT espetialVariable { $expressionRet = new MethodCall($expression.expressionRet, $espetialVariable.espVarRet); }
           | expression (INC{$op1 = UnaryOperator.INC; $Line = $INC.line;} | DEC{$op1 = UnaryOperator.DEC; $Line = $DEC.line;}) { $expressionRet = new UnaryExpression($op1, $expression.expressionRet); $expressionRet.setLine($Line); }
           | (NOT {$op1 = UnaryOperator.NOT; $Line = $NOT.line;} | MINUS {$op1 = UnaryOperator.MINUS; $Line = $MINUS.line;} | BIT_NOT {$op1 = UnaryOperator.BIT_NOT; $Line = $BIT_NOT.line;} | INC {$op1 = UnaryOperator.INC; $Line = $INC.line;} | DEC{$op1 = UnaryOperator.DEC; $Line = $DEC.line;}) expression { $expressionRet = new UnaryExpression($op1, $expression.expressionRet); $expressionRet.setLine($Line); }
           | lexpr=expression (MULT {$op2 = BinaryOperator.MULT; $Line = $MULT.line;} | DIV {$op2 = BinaryOperator.DIV; $Line = $DIV.line;} | MOD {$op2 = BinaryOperator.MOD; $Line = $MOD.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (PLUS {$op2 = BinaryOperator.PLUS; $Line = $PLUS.line;} | MINUS {$op2 = BinaryOperator.MINUS; $Line = $MINUS.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (L_SHIFT {$op2 = BinaryOperator.L_SHIFT; $Line = $L_SHIFT.line;} | R_SHIFT {$op2 = BinaryOperator.R_SHIFT; $Line = $R_SHIFT.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (LT {$op2 = BinaryOperator.LT; $Line = $LT.line;} | GT {$op2 = BinaryOperator.GT; $Line = $GT.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (EQ {$op2 = BinaryOperator.EQ; $Line = $EQ.line;} | NEQ {$op2 = BinaryOperator.NEQ; $Line = $NEQ.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression (BIT_AND {$op2 = BinaryOperator.BIT_AND; $Line = $BIT_AND.line;} | BIT_OR {$op2 = BinaryOperator.BIT_OR; $Line = $BIT_OR.line;} | BIT_XOR {$op2 = BinaryOperator.BIT_XOR; $Line = $BIT_XOR.line;}) rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression AND {$op2 = BinaryOperator.AND; $Line = $AND.line;} rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | lexpr=expression OR {$op2 = BinaryOperator.OR; $Line = $OR.line;} rexpr=expression { $expressionRet = new BinaryExpression($lexpr.expressionRet, $rexpr.expressionRet, $op2); $expressionRet.setLine($Line); }
           | ID {boolean temp = false;}(LBRACK expression RBRACK {temp = true;})? { if(temp) $expressionRet = new ArrayIdentifier($ID.text, $expression.expressionRet); else $expressionRet = new Identifier($ID.text); $expressionRet.setLine($ID.line); }
           | LPAREN expression RPAREN { $expressionRet = $expression.expressionRet; }
           | functionCall { $expressionRet =  $functionCall.funCallRet; }
           | methodCall { $expressionRet = $methodCall.methCallRet; };

value returns [Value valueRet] locals [float temp]:
    INT_LITERAL  { $valueRet = new IntValue($INT_LITERAL.int); $valueRet.setLine($INT_LITERAL.line); }
    | FLOAT_LITERAL { $valueRet = new FloatValue(Float.valueOf($FLOAT_LITERAL.text)); $valueRet.setLine($FLOAT_LITERAL.line); }
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
