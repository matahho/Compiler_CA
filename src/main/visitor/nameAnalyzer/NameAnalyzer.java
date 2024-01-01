package main.visitor.nameAnalyzer;

import main.ast.node.Program;
import main.ast.node.declaration.*;
import main.ast.node.statement.Statement;
import main.compileError.CompileError;
import main.compileError.name.*;
import main.symbolTable.SymbolTable;
import main.symbolTable.itemException.ItemAlreadyExistsException;
import main.symbolTable.itemException.ItemNotFoundException;
import main.symbolTable.symbolTableItems.*;
import main.visitor.Visitor;

import java.util.ArrayList;
import java.util.List;

public class NameAnalyzer extends Visitor<Void> {

    public ArrayList<CompileError> nameErrors = new ArrayList<>();
    private static ArrayList<String> preDefined = new ArrayList<>(
            List.of("int", "string", "for", "while", "else", "if",
                    "continue", "try", "false", "true", "float", "bool",
                    "OnInit", "OnStart", "throw", "return", "catch", "break",
                    "void", "double", "Main", "Digits", "BUY", "SELL", "Bid",
                    "Ask", "Type", "Volume", "Low", "High", "Close", "Open",
                    "Time", "Text", "Trade", "Order", "Candle", "Exception",
                    "RefreshRate", "GetCandle", "Terminate", "Connect", "Observe",
                    "Print", "Preorder", "parallel")
    );

    @Override
    public Void visit(Program program) {
        SymbolTable.root = new SymbolTable();
        SymbolTable.push(SymbolTable.root);

        for (VarDeclaration varDeclaration : program.getVars())
            varDeclaration.accept(this);
        for (FunctionDeclaration functionDeclaration : program.getFunctions())
            functionDeclaration.accept(this);
        for (OnInitDeclaration onInitDeclaration : program.getInits())
            onInitDeclaration.accept(this);
        for (OnStartDeclaration onStartDeclaration : program.getStarts())
            onStartDeclaration.accept(this);
        if(program.getMain() != null)
            program.getMain().accept(this);
        return null;
    }

    @Override
    public Void visit(OnInitDeclaration onInitDeclaration) {
        OnInitItem onInitItem = new OnInitItem(onInitDeclaration);
        SymbolTable onInitSymbolTable = new SymbolTable(SymbolTable.top, onInitDeclaration.getTradeName().getName());
        onInitItem.setOnInitSymbolTable(onInitSymbolTable);

        // TODO check the onInit name is redundant or not , if it is redundant change its name and put it
        try {
            SymbolTable.root.put(onInitItem); //TODO : top or root??
            VarDeclaration var = new VarDeclaration();
            var.setIdentifier(onInitDeclaration.getTradeName());
            VariableItem onInitTrade = new VariableItem(var);
            onInitSymbolTable.put(onInitTrade);
        } catch (ItemAlreadyExistsException ex) {
            nameErrors.add(new PrimitiveFunctionRedefinition(onInitDeclaration.getLine(), onInitDeclaration.getTradeName().getName()));
        }

        // TODO push onInit symbol table
        SymbolTable.push(onInitSymbolTable);

        // TODO visit statements
        if(onInitDeclaration.getBody() != null){
            for(Statement stmt : onInitDeclaration.getBody()){
                if(stmt instanceof VarDeclaration || stmt instanceof FunctionDeclaration){
                    stmt.accept(this);
                }
            }
        }

        // TODO pop onInit symbol table
        SymbolTable.pop();

        return null;
    }

    @Override
    public Void visit(OnStartDeclaration onStartDeclaration) {
        OnStartItem onStartItem = new OnStartItem(onStartDeclaration);
        SymbolTable onStartSymbolTable = new SymbolTable(SymbolTable.top, onStartDeclaration.getTradeName().getName());
        onStartItem.setOnStartSymbolTable(onStartSymbolTable);

        // TODO check the onInit name is redundant or not , if it is redundant change its name and put it
        try {
            SymbolTable.root.put(onStartItem); //TODO : top or root?
            VarDeclaration var = new VarDeclaration();
            var.setIdentifier(onStartDeclaration.getTradeName());
            VariableItem onStartTrade = new VariableItem(var);
            onStartSymbolTable.put(onStartTrade);
        } catch (ItemAlreadyExistsException ex) {
            nameErrors.add(new PrimitiveFunctionRedefinition(onStartDeclaration.getLine(), onStartDeclaration.getTradeName().getName()));
        }

        // TODO push onInit symbol table
        SymbolTable.push(onStartSymbolTable);

        // TODO visit statements
        if(onStartDeclaration.getBody() != null){
            for(Statement stmt : onStartDeclaration.getBody()){
                if(stmt instanceof VarDeclaration || stmt instanceof FunctionDeclaration){
                    stmt.accept(this);
                }
            }
        }

        // TODO pop onInit symbol table
        SymbolTable.pop();

        return null;
    }

    @Override
    public Void visit(MainDeclaration mainDeclaration) {
        MainItem mainItem = new MainItem(mainDeclaration);
        SymbolTable mainSymbolTable = new SymbolTable(SymbolTable.top, "Main");
        mainItem.setMainSymbolTable(mainSymbolTable);

        //TODO : NO NEED TO CHECK FOR MAIN BEING UNIQUE

        // TODO push onInit symbol table
        SymbolTable.push(mainSymbolTable);

        // TODO visit statements
        if(mainDeclaration.getBody() != null){
            for(Statement stmt : mainDeclaration.getBody()){
                if(stmt instanceof VarDeclaration || stmt instanceof FunctionDeclaration){
                    stmt.accept(this);
                }
            }
        }

        // TODO pop onInit symbol table
        SymbolTable.pop();

        return null;
    }

    @Override
    public Void visit(FunctionDeclaration functionDeclaration) {
        FunctionItem funcItem = new FunctionItem(functionDeclaration);
        SymbolTable funcSymbolTable = new SymbolTable(SymbolTable.top, functionDeclaration.getName().getName());
        funcItem.setHandlerSymbolTable(funcSymbolTable);

        try {
            SymbolTable.root.put(funcItem);
        } catch (ItemAlreadyExistsException ex) {
            nameErrors.add(new MethodRedefinition(functionDeclaration.getLine(), functionDeclaration.getName().getName()));
        }



        /*This Part was not supposed to be handled in Project but was handled in samples!*/
        VarDeclaration temp = new VarDeclaration();
        temp.setIdentifier(functionDeclaration.getName());
        VariableItem tempItem = new VariableItem(temp);
        try {
            SymbolTable.root.get(tempItem.getKey());
            nameErrors.add(new FunctionVariableConflict(functionDeclaration.getLine(), functionDeclaration.getName().getName()));
        } catch (ItemNotFoundException ex) {}
        /*-------------------------------------------------------------------------------*/
        SymbolTable.push(funcSymbolTable);

        if(functionDeclaration.getArgs() != null) {
            for (VarDeclaration var : functionDeclaration.getArgs()) {
                /*Checks that function's name and it's arguments are not the same.
                (Extra condition, wasnt in the Project Description)*/
                if(var.getIdentifier().getName().equals(functionDeclaration.getName().getName())){
                    nameErrors.add(new FunctionVariableConflict(functionDeclaration.getLine(), functionDeclaration.getName().getName()));
                }
                /*-------------------------------------------------------------------------------------------------------*/
                var.accept(this);
            }
        }

        if(functionDeclaration.getBody() != null) {
            for (Statement stmt : functionDeclaration.getBody()) {
                if (stmt instanceof VarDeclaration) {
                    /*This Part was supposed to be handled in Project Description but is unknown after samples were released?*/
                    if(((VarDeclaration) stmt).getIdentifier().getName().equals(functionDeclaration.getName().getName())){
                        nameErrors.add(new FunctionVariableConflict(functionDeclaration.getLine(), functionDeclaration.getName().getName()));
                    }
                    /*-------------------------------------------------------------------------------------------------------*/
                    stmt.accept(this);
                } else if (stmt instanceof FunctionDeclaration) {
                    stmt.accept(this);
                }
            }
        }
        return null;
    }

    @Override
    public Void visit(VarDeclaration varDeclaration) {
        VariableItem varItem = new VariableItem(varDeclaration);
        if(preDefined.contains(varDeclaration.getIdentifier().getName())) {
            nameErrors.add(new IrregularDefenition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
        } else {
            if (SymbolTable.top.equals(SymbolTable.root)) {
                try {
                    SymbolTable.root.put(varItem);
                } catch (ItemAlreadyExistsException ex) {
                    nameErrors.add(new GlobalVariableRedefinition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
                }
            } else {
                try {
                    SymbolTable.root.get(varItem.getKey());
                    nameErrors.add(new GlobalVariableRedefinition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
                } catch (ItemNotFoundException ex) {
                    try {
                        SymbolTable.top.put(varItem);
                    } catch (ItemAlreadyExistsException exx) {
                        nameErrors.add(new VariableRedefinition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
                    }
                }
            }
        }
        //if(preDefinedVar.contains(varDeclaration.getIdentifier().getName())){
        //   nameErrors.add(new IrregularDefenition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
        //}
        return null;
    }
}

