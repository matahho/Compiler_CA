package main.ast.type;

import main.ast.node.Node;

public abstract class Type {
    private int line;
    public void setLine(int line_num) {
        this.line = line_num;
    }
    public int getLine() {
        return this.line;
    }
    public String getName(){return null;}
}
