package main.ast.node.declaration;

import main.ast.node.expression.Identifier;
import main.ast.type.Type;
import main.visitor.IVisitor;
import main.ast.node.expression.Expression;

public class VarDeclaration extends Declaration {
    private Type type;
    private Identifier identifier;
    private Expression expr;
    private int length = 0; // > 0 means array

    public VarDeclaration() {
    }

    public Identifier getIdentifier() {
        return this.identifier;
    }
    public Expression getExpression() { return this.expr; }

    public void setIdentifier(Identifier identifier) {
        this.identifier = identifier;
    }
    public void setExpression(Expression expr) { this.expr = expr; }

    @Override
    public Type getType() {
        return this.type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public int getLength() {
        return this.length;
    }

    public void setLength(int length) {
        this.length = length;
    }

    public boolean isArray() {
        return this.length > 0;
    }

    @Override
    public String toString(){ return "VarDeclaration"; }
    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
