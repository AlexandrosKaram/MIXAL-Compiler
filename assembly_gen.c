#include <stdio.h>
#include <string.h>
#include "ast.h"
#include "symbol.h"
#include "assembly_gen.h"

int variable_count = 0; 
static int temp_count = 1;

void generateProgramCode(AstNode* node) {
    fprintf(assemblyFile, " ORIG 2000\n");
    generateMixalCode(node->left);
    fprintf(assemblyFile, " END 2000\n");
}


extern Symbol *symbolTable;

void generateAssignmentCode(AstNode* node) {
    Symbol *symbol = findSymbol(node->left->value, symbolTable);
    
    if (symbol == NULL) {
        declareVariable(node->left->value, &symbolTable);
        symbol = findSymbol(node->left->value, symbolTable);
        fprintf(assemblyFile, " STZ %d(0:5)\n", symbol->memoryLocation);
    }

    generateMixalCode(node->right);
    fprintf(assemblyFile, " STA %d(0:5)\n", symbol->memoryLocation);
}


void generateNumber(AstNode* node) {
    fprintf(assemblyFile, " ENTA %s\n", node->value);
}

void generateID(AstNode* node) {
    Symbol *symbol = findSymbol(node->value, symbolTable);
    if (symbol != NULL) {
        fprintf(assemblyFile, " LDA %d(0:5)\n", symbol->memoryLocation);
    }
}


void generateIfCode(AstNode* node) {
    if ((node->nodeType == IF_NODE) && (node->right->nodeType != ELSE_NODE)) {

        generateMixalCode(node->left);

        if (node->left->nodeType == LT_NODE) {
            fprintf(assemblyFile, " JL THEN\n");
        } else if (node->left->nodeType == EQ_NODE) {
            fprintf(assemblyFile, " JE THEN\n");
        }

        fprintf(assemblyFile," JMP ENDIF\n");
        fprintf(assemblyFile, "THEN NOP\n");
        generateMixalCode(node->right->left);
        generateMixalCode(node->right->right);
        
        fprintf(assemblyFile, " JMP ENDIF\n");
        fprintf(assemblyFile, "ENDIF NOP\n");
    } else if ((node->nodeType == IF_NODE)&& (node->right->nodeType == ELSE_NODE)){

        generateMixalCode(node->left);

        if (node->left->nodeType == LT_NODE) {
            fprintf(assemblyFile, " JL THEN\n");
        } else if (node->left->nodeType == EQ_NODE) {
            fprintf(assemblyFile, " JE THEN\n");
        }

        fprintf(assemblyFile, " JMP ELSE\n");
        fprintf(assemblyFile, "THEN NOP\n");
        generateMixalCode(node->right->left);
        fprintf(assemblyFile, " JMP ENDIF\n");
        fprintf(assemblyFile, "ELSE NOP\n");
        generateMixalCode(node->right->right);
        fprintf(assemblyFile, " JMP ENDIF\n");
        fprintf(assemblyFile, "ENDIF NOP\n");
    }
}


void generatePlus(AstNode* node) {
    int addTemp = temp_count++;
    fprintf(assemblyFile, "TEMP%d EQU 0\n", addTemp);

    generateMixalCode(node->left);
    fprintf(assemblyFile, " STA TEMP%d\n", addTemp);
    generateMixalCode(node->right);
    fprintf(assemblyFile, " ADD TEMP%d\n", addTemp);
}



void generateMinus(AstNode* node) {
    int subTemp = temp_count++;
    fprintf(assemblyFile, "OPPTEMP EQU 0\n");
    fprintf(assemblyFile, "TEMP%d EQU 0\n", subTemp);

    generateMixalCode(node->left);
    fprintf(assemblyFile, " STA TEMP%d\n", subTemp);

    generateMixalCode(node->right);
    fprintf(assemblyFile, " SUB TEMP%d\n", subTemp);

    fprintf(assemblyFile, " STA OPPTEMP\n");
    fprintf(assemblyFile, " ENTA 0\n");
    fprintf(assemblyFile, " SUB OPPTEMP\n");
}


void generateMul(AstNode* node) {
    int mulTemp = temp_count++;
    fprintf(assemblyFile, "TEMP%d EQU 0\n", mulTemp);

    fprintf(assemblyFile, " STZ TEMP%d\n", mulTemp);

    generateMixalCode(node->left);

    fprintf(assemblyFile, " STA TEMP%d\n", mulTemp);

    generateMixalCode(node->right);

    fprintf(assemblyFile, " MUL TEMP%d\n", mulTemp);
    fprintf(assemblyFile, " STX TEMP%d\n", mulTemp);
    fprintf(assemblyFile, " LDA TEMP%d\n", mulTemp);
    fprintf(assemblyFile, " ENTX 0\n");
}


void generateDiv(AstNode* node) {
    int divTemp = temp_count++;
    fprintf(assemblyFile, "TEMP%d EQU 0\n", divTemp);
    fprintf(assemblyFile, "SWAPTEMP EQU 1\n");

    generateMixalCode(node->left);

    fprintf(assemblyFile, " STA TEMP%d\n", divTemp);
    temp_count++;

    generateMixalCode(node->right);

    // Εκτέλεση της διαίρεσης, αντιστροφή και φόρτωση τιμών
    fprintf(assemblyFile, " STA SWAPTEMP\n");          // Αποθήκευση του A στο SWAPTEMP
    fprintf(assemblyFile, " LDX SWAPTEMP\n");          // Φόρτωση του A στον X
    fprintf(assemblyFile, " LDA TEMP%d\n", divTemp);   // Φόρτωση του προσωρινού αποτελέσματος στον A
    fprintf(assemblyFile, " STX TEMP%d\n", divTemp);   // Αποθήκευση του X στο TEMP
    fprintf(assemblyFile, " STA SWAPTEMP\n");          // Αποθήκευση του A στο SWAPTEMP
    fprintf(assemblyFile, " LDX SWAPTEMP\n");          // Φόρτωση του SWAPTEMP στον X
    fprintf(assemblyFile, " ENTA 0\n");                // Μηδενισμός του καταχωρητή A
    fprintf(assemblyFile, " DIV TEMP%d\n", divTemp);   // Διαίρεση με το TEMP
}


void generateLT(AstNode* node) {
    generateMixalCode(node->left);

    Symbol *symbol = findSymbol(node->right->value, symbolTable);
    if (symbol != NULL) {
        fprintf(assemblyFile, " CMPA %d(0:5)\n", symbol->memoryLocation);
    } else {
        fprintf(stderr, "Error: Variable %s not found in symbol table.\n", node->right->value);
    }
}


void generateEQ(AstNode* node) {
    generateMixalCode(node->left);

    Symbol *symbol = findSymbol(node->right->value, symbolTable);
    if (symbol != NULL) {
        fprintf(assemblyFile, " CMPA %d(0:5)\n", symbol->memoryLocation);
    } else {
        fprintf(stderr, "Error: Variable %s not found in symbol table.\n", node->right->value);
    }
}

void generateReadCode(AstNode* node) {
    Symbol *symbol = findSymbol(node->value, symbolTable);
    printf("Mphke sthn generate Read Code\n");
    if (symbol != NULL) {
        printf("To symbol htan diaforo tou NULL\n");
        int input_buffer_address = 1000;
        int input_device = 19;

        fprintf(assemblyFile, " IN %d(%d)\n", input_buffer_address, input_device);

        fprintf(assemblyFile, " JBUS *(%d)\n", input_device);

        fprintf(assemblyFile, " LDX %d(0:5)\n", input_buffer_address);

        fprintf(assemblyFile, " NUM\n");

        fprintf(assemblyFile, " STA %d(0:5)\n", symbol->memoryLocation);
    } else {
        fprintf(stderr, "Error: Variable %s not found in symbol table.\n", node->value);
    }
}

void generateRepeatCode(AstNode* node) {
    static int repeatLabelCounter = 0;
    int currentRepeatLabel = repeatLabelCounter++;

    fprintf(assemblyFile, "REPEAT%d NOP\n", currentRepeatLabel);
    generateMixalCode(node->left);

    Symbol *rightSymbol = findSymbol(node->right->left->value, symbolTable);
    if (rightSymbol != NULL) {
        fprintf(assemblyFile, " LDA %d(0:5)\n", rightSymbol->memoryLocation);

        if (node->right->right->nodeType == CONST_NODE) {
            fprintf(assemblyFile, " ENTA %s\n", node->right->right->value);
        }

        fprintf(assemblyFile, " CMPA 1(0:5)\n");
        fprintf(assemblyFile, " JE ENDREPEAT%d\n", currentRepeatLabel);
    }

    fprintf(assemblyFile, " JMP REPEAT%d\n", currentRepeatLabel);

    fprintf(assemblyFile, "ENDREPEAT%d NOP\n", currentRepeatLabel);
}

int write_counter = 0;

void generateWriteCode(AstNode* node) {
    Symbol *symbol = findSymbol(node->value, symbolTable);
    if (symbol != NULL) {
        int current_write = write_counter++;

        fprintf(assemblyFile, " LDA %d(0:5)\n", symbol->memoryLocation);

        fprintf(assemblyFile, " CHAR\n");

        fprintf(assemblyFile, " STA 1987(0:5)\n");

        fprintf(assemblyFile, " STX 1988(0:5)\n");

        fprintf(assemblyFile, " ENTX 45\n");
        fprintf(assemblyFile, " JAN KPO%d\n", current_write);
        fprintf(assemblyFile, " ENTX 44\n");
        fprintf(assemblyFile, "KPO%d NOP\n", current_write);

        fprintf(assemblyFile, " STX 1986(0:5)\n");

        fprintf(assemblyFile, " OUT 1986(2:3)\n");
    } else {
        fprintf(stderr, "Error: Variable %s not found in symbol table.\n", node->value);
    }
}


void generateSeqCode(AstNode* node) {
    if (node->nodeType == SEQ_NODE) {
        generateMixalCode(node->left);
        generateMixalCode(node->right);
    }
}


void generateMixalCode(AstNode* node) {
    if (node == NULL) return;

    switch (node->nodeType) {
        case PROGRAM_NODE:
            generateProgramCode(node);
            break;
        case ASSIGN_NODE:
            generateAssignmentCode(node);
            break;
        case IF_NODE:
            generateIfCode(node);
            break;
        case WRITE_NODE:
            generateWriteCode(node);
            break;
        case READ_NODE:
            generateReadCode(node);
            break;
        case SEQ_NODE:
            generateSeqCode(node);
            break;
        case CONST_NODE:
            generateNumber(node);
            break;
        case IDENT_NODE:
            generateID(node);
            break;
        case PLUS_NODE:
            generatePlus(node);
            break;
        case MINUS_NODE:
            generateMinus(node);
            break;
        case MUL_NODE:
            generateMul(node);
            break;
        case DIV_NODE:
            generateDiv(node);
            break;
        case LT_NODE:
            generateLT(node);
            break;
        case EQ_NODE:
            generateEQ(node);
            break;
        case REPEAT_NODE:
            generateRepeatCode(node);
            break;
        default:
            fprintf(assemblyFile, "NOP\n");
    }
}