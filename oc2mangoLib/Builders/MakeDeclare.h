//
//  MakeDeclare.h
//  oc2mango
//
//  Created by Jiang on 2019/4/21.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
#import "RunnerClasses.h"


ORTypeNode *makeTypeNode(TypeKind type, NSString *name);
ORTypeNode *makeTypeNode(TypeKind type) __attribute__((overloadable)) ;
extern ORVariableNode *makeVarNode(NSString *name, NSUInteger ptCount);
extern ORVariableNode *makeVarNode(NSString *name) __attribute__((overloadable)) ;

extern ORClassNode *makeOCClass(NSString *className);
extern ORProtocolNode *makeORProtcol(NSString *protocolName);
extern ORPropertyNode *makePropertyDeclare(NSMutableArray *keywords, ORDeclaratorNode *var);
extern ORMethodDeclNode *makeMethodDeclare(BOOL isClassMethod, ORDeclaratorNode *returnType);
extern ORMethodNode *makeMethodImplementation(ORMethodDeclNode *declare, ORBlockNode *scopeImp);
extern ORFunctionDeclNode *makeFunctionSignNode(void);
extern ORMethodCall *makeMethodCall(void);

extern ORValueNode *makeValue(OC_VALUE_TYPE type, id value);
extern ORValueNode *makeValue(OC_VALUE_TYPE type) __attribute__((overloadable)) ;

extern ORBlockNode *makeScopeImp(void);
extern ORFunctionCall *makeFuncCall(ORNode *caller, NSMutableArray *expressions);
extern ORUnaryExpression *makeUnaryExpression(UnaryOperatorType type);
extern ORBinaryExpression *makeBinaryExpression(BinaryOperatorType type);
extern ORTernaryExpression *makeTernaryExpression(void);
extern ORAssignExpression *makeAssignExpression(AssignOperatorType type);

extern ORDeclaratorNode *makeDeclaratorNode(ORTypeNode *type,ORVariableNode *var);
extern ORInitDeclaratorNode *makeInitDeclaratorNode(ORDeclaratorNode *declarator,ORNode * exp);
extern ORFunctionDeclNode *makeFunctionDeclarator(void);
extern ORSubscriptNode *makeSubscriptNode(ORNode *caller, ORNode *key);

extern ORFunctionNode *makeFunctionNode(ORFunctionDeclNode *decl, ORBlockNode *block);
extern ORIfStatement *makeIfStatement(ORNode *judgement, ORBlockNode *imp);
extern ORWhileStatement *makeWhileStatement(ORNode *judgement, ORBlockNode *imp);
extern ORDoWhileStatement *makeDoWhileStatement(ORNode *judgement, ORBlockNode *imp);
extern ORCaseStatement *makeCaseStatement(ORValueNode *value);
extern ORSwitchStatement *makeSwitchStatement(ORValueNode *value);
extern ORForStatement *makeForStatement(ORBlockNode *imp);
extern ORForInStatement *makeForInStatement(ORBlockNode *imp);

extern ORControlStatNode *makeControlStatement(ORControlStateType type,ORNode * expression);

extern ORTypedefStatNode *makeTypedefExp(id exp,NSString *newName);
extern ORStructStatNode *makeStructExp(NSString *name, NSMutableArray *fields);
extern ORUnionStatNode *makeUnionExp(NSString *name, NSMutableArray *fields);
extern OREnumStatNode *makeEnumExp(NSString *name, ORTypeNode *type, NSMutableArray *fields);

extern ORNode *makeIntegerValue(uint64_t value);
extern ORDoubleValue *makeDoubleValue(double value);
extern ORBoolValue *makeBoolValue(BOOL value);

void startStringBuffer(void);
char *endStringBuffer(void);
void stringBufferAppendCharacter(char chr);
void stringBufferAppendString(char *str);

NSMutableArray *makeMutableArray(id object);
