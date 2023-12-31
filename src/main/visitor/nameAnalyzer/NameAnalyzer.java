package main.visitor.nameAnalyzer;

import main.ast.node.Program;
import main.ast.node.declaration.*;
import main.ast.node.statement.Statement;
import main.compileError.CompileError;
import main.compileError.name.*;
import main.symbolTable.SymbolTable;
import main.symbolTable.itemException.ItemAlreadyExistsException;
import main.symbolTable.itemException.ItemNotFoundException;
import main.symbolTable.symbolTableItems.FunctionItem;
import main.symbolTable.symbolTableItems.OnInitItem;
import main.symbolTable.symbolTableItems.VariableItem;
import main.visitor.Visitor;

import javax.swing.plaf.synth.SynthButtonUI;
import java.util.ArrayList;

public class NameAnalyzer extends Visitor<Void> {

    public ArrayList<CompileError> nameErrors = new ArrayList<>();

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
        // TODO

        return null;
    }

    @Override
    public Void visit(MainDeclaration mainDeclaration) {
        // TODO

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

        SymbolTable.push(funcSymbolTable);

        if(functionDeclaration.getBody() != null) {
            for (Statement stmt : functionDeclaration.getBody()) {
                if (stmt instanceof VarDeclaration || stmt instanceof FunctionDeclaration) {
                    stmt.accept(this);
                }
            }
        }
        return null;
    }

    @Override
    public Void visit(VarDeclaration varDeclaration) {
        VariableItem varItem = new VariableItem(varDeclaration);

        if(SymbolTable.top.equals(SymbolTable.root)){
            try {
                SymbolTable.root.put(varItem);
            } catch (ItemAlreadyExistsException ex){
                nameErrors.add(new GlobalVariableRedefinition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
            }
        }
        else {
            try {
                SymbolTable.root.get(varDeclaration.getIdentifier().getName());
                nameErrors.add(new GlobalVariableRedefinition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
            } catch (ItemNotFoundException ex){
                try {
                    SymbolTable.top.put(varItem);
                } catch (ItemAlreadyExistsException exx) {
                    nameErrors.add(new VariableRedefinition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
                }
            }
        }
        //if(preDefinedVar.contains(varDeclaration.getIdentifier().getName())){
        //   nameErrors.add(new IrregularDefenition(varDeclaration.getLine(), varDeclaration.getIdentifier().getName()));
        //}
        return null;
    }
}

