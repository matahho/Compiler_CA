package main.visitor.astPrinter;

import com.sun.jdi.event.StepEvent;
import main.ast.node.Program;
import main.ast.node.declaration.*;
import main.ast.node.statement.*;
import main.visitor.Visitor;

public class ASTPrinter extends Visitor<Void> {
    public void messagePrinter(int line, String message){
        System.out.println("Line:" + line + ":" + message);
    }

    @Override
    public Void visit(Program program) {
        messagePrinter(program.getLine(), program.toString());
        for (VarDeclaration varDeclaration : program.getVars())
            varDeclaration.accept(this);
        for (FunctionDeclaration functionDeclaration : program.getFunctions())
            functionDeclaration.accept(this);
        for (OnInitDeclaration onInitDeclaration : program.getInits())
            onInitDeclaration.accept(this);
        for (OnStartDeclaration onStartDeclaration : program.getStarts())
            onStartDeclaration.accept(this);
        program.getMain().accept(this);
        return null;
    }

    //Statement Rule

    //varDeclaration Rule
    @Override
    public Void visit(VarDeclaration varDeclaration){
        messagePrinter(varDeclaration.getLine() , varDeclaration.toString());
        if (varDeclaration.getIdentifier() != null){
            varDeclaration.getIdentifier().accept(this);
        }
        return null;
    }

    //functionDeclaration Rule
    @Override
    public Void visit(FunctionDeclaration functionDeclaration){
        messagePrinter(functionDeclaration.getLine() , functionDeclaration.toString());
        if (functionDeclaration.getName() != null){
            functionDeclaration.getName().accept(this);
        }
        if (functionDeclaration.getArgs() != null){
            for (VarDeclaration varDec : functionDeclaration.getArgs()){
                varDec.accept(this);
            }
        }
        if (functionDeclaration.getBody() != null){
            for(Statement stmt: functionDeclaration.getBody()){
                stmt.accept(this);
            }
        }
        return null;
    }

    //mainDeclaration Rule
    @Override
    public Void visit(MainDeclaration mainDeclaration){
        messagePrinter(mainDeclaration.getLine() , mainDeclaration.toString());
        if (mainDeclaration.getMainTrades() != null){
            for (VarDeclaration varDeclaration : mainDeclaration.getMainTrades()){
                varDeclaration.accept(this);
            }
        }
        if (mainDeclaration.getBody() != null){
            for (Statement statement : mainDeclaration.getBody()){
                statement.accept(this);
            }
        }
        return null;
    }


    //initDeclaration Rule
    @Override
    public Void visit(OnInitDeclaration onInitDeclaration){
        messagePrinter(onInitDeclaration.getLine() , onInitDeclaration.toString());
        if (onInitDeclaration.getTradeName() != null){
            onInitDeclaration.getTradeName().accept(this);
        }
        if (onInitDeclaration.getBody() != null) {
            for (Statement statement : onInitDeclaration.getBody()) {
                statement.accept(this);
            }
        }
        return null;
    }

    //startDeclaration Rule
    @Override
    public Void visit(OnStartDeclaration onStartDeclaration){
        messagePrinter(onStartDeclaration.getLine() , onStartDeclaration.toString());
        if (onStartDeclaration.getTradeName() != null){
            onStartDeclaration.getTradeName().accept(this);
        }
        if (onStartDeclaration.getBody() != null) {
            for (Statement statement : onStartDeclaration.getBody()) {
                statement.accept(this);
            }
        }
        return null;
    }

    //assignStatement Rule
    @Override
    public Void visit(AssignStmt assignStmt){
        messagePrinter(assignStmt.getLine() , assignStmt.toString());
        if (assignStmt.getLValue() != null){
            assignStmt.getLValue().accept(this);
        }
        if (assignStmt.getRValue() != null){
            assignStmt.getRValue().accept(this);
        }
        return  null;

    }

    //ifStatement Rule
    @Override
    public Void visit(IfElseStmt ifElseStmt){
        messagePrinter(ifElseStmt.getLine() , ifElseStmt.toString());
        ifElseStmt.getCondition().accept(this);
        if (ifElseStmt.getThenBody() != null){
            for (Statement statement : ifElseStmt.getThenBody()) {
                statement.accept(this);
            }
        }
        if (ifElseStmt.getElseBody() != null){
            for (Statement statement : ifElseStmt.getElseBody()) {
                statement.accept(this);
            }
        }
        return null;
    }

    //whileStatement Rule
    @Override
    public Void visit(WhileStmt whileStmt){
        messagePrinter(whileStmt.getLine() , whileStmt.toString());
        if (whileStmt.getCondition() != null){
            whileStmt.getCondition().accept(this);
        }
        if (whileStmt.getBody() != null){
            for (Statement statement : whileStmt.getBody()){
                statement.accept(this);
            }
        }
        return null;
    }

    //forStatement Rule
    @Override
    public Void visit(ForStmt forStmt){
        messagePrinter(forStmt.getLine() , forStmt.toString());
        if (forStmt.getInit() != null){
            for (Statement statement : forStmt.getInit()){
                statement.accept(this);
            }
        }
        if (forStmt.getCondition() != null){
            forStmt.getCondition().accept(this);
        }
        if (forStmt.getUpdate() != null) {
            for (Statement statement : forStmt.getUpdate()) {
                statement.accept(this);
            }
        }
        if (forStmt.getBody() != null) {
            for (Statement statement : forStmt.getBody()) {
                statement.accept(this);
            }
        }
        return null;
    }

    //tryCatchStatement Rule
    //TODO : There is a Condition in TryCatchStmt Constructor
    @Override
    public Void visit (TryCatchStmt tryCatchStmt){
        messagePrinter(tryCatchStmt.getLine() , tryCatchStmt.toString());
        if (tryCatchStmt.getThenBody() != null){
            for (Statement statement : tryCatchStmt.getThenBody()){
                statement.accept(this);
            }
        }
        if (tryCatchStmt.getElseBody() != null){
            for (Statement statement : tryCatchStmt.getElseBody()){
                statement.accept(this);
            }
        }
    return null;
    }

    //continueBreakStatement Rule
    //TODO : There is a string token in continueBreakStatement Constuctur
    @Override
    public Void visit(ContinueBreakStmt continueBreakStmt){
        messagePrinter(continueBreakStmt.getLine() , continueBreakStmt.toString());
//        if (continueBreakStmt.getToken() != null){
//
//        }
//        return null;
        return null;
    }


    //returnStatement Rule
    @Override
    public Void visit(ReturnStmt returnStmt){
        messagePrinter(returnStmt.getLine() , returnStmt.toString());
        if (returnStmt.getReturnedExpr() != null){
            returnStmt.getReturnedExpr().accept(this);
        }
        return null;
    }





}

