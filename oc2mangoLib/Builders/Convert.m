//
//  Convert.m
//  oc2mangoLib
//
//  Created by Jiang on 2019/5/18.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//

#import "Convert.h"
#import "MakeDeclare.h"
BOOL is_left_value = true;
@implementation Convert
- (NSString *)convert:(ORNode *)node{
    NSString *result = @"";
    if ([node isKindOfClass:[ORDeclaratorNode class]]){
        result = [self convertDeclaratorNode:(ORDeclaratorNode *)node];
    }else if ([node isKindOfClass:[ORInitDeclaratorNode class]]) {
        result = [self convertInitDeclareExp:(ORInitDeclaratorNode *)node];
    }else if ([node isKindOfClass:[ORAssignNode class]]) {
        result = [self convertAssginExp:(ORAssignNode *)node];
    }else if ([node isKindOfClass:[ORValueNode class]]){
        result = [self convertOCValue:(ORValueNode *)node];
    }else if ([node isKindOfClass:[ORIntegerValue class]]){
        result = [self convertORIntegerValue:(ORIntegerValue *)node];
    }else if ([node isKindOfClass:[ORIntegerValue class]]){
        result = [self convertORUIntegerValue:(ORUIntegerValue *)node];
    }else if ([node isKindOfClass:[ORDoubleValue class]]){
        result = [self convertORDoubleValue:(ORDoubleValue *)node];
    }else if ([node isKindOfClass:[ORBoolValue class]]){
        result = [self convertORBoolValue:(ORBoolValue *)node];
    }else if ([node isKindOfClass:[ORBinaryNode class]]){
        result = [self convertBinaryExp:(ORBinaryNode *)node];
    }else if ([node isKindOfClass:[ORUnaryNode class]]){
        result = [self convertUnaryExp:(ORUnaryNode *)node];
    }else if ([node isKindOfClass:[ORTernaryNode class]]){
        result = [self convertTernaryExp:(ORTernaryNode *)node];
    }else if ([node isKindOfClass:[ORFunctionNode class]]){
        result = [self convertBlockImp:(ORFunctionNode *)node];
    }else if ([node isKindOfClass:[ORMethodCall class]]){
        result = [self convertOCMethodCall:(ORMethodCall *)node];
    }else if ([node isKindOfClass:[ORFunctionCall class]]){
        result = [self convertFunCall:(ORFunctionCall *)node];
    }else if ([node isKindOfClass:[ORSubscriptNode class]]){
        result = [self convertSubscript:(ORSubscriptNode *)node];
    } else if ([node isKindOfClass:[ORControlStatNode class]]) {
        result = [self convertControlStatement:(ORControlStatNode *) node];
    }else if ([node isKindOfClass:[ORIfStatement class]]) {
        result = [self convertIfStatement:(ORIfStatement *) node];
    }else if([node isKindOfClass:[ORWhileStatement class]]){
        result = [self convertWhileStatement:(ORWhileStatement *) node];
    }else if([node isKindOfClass:[ORDoWhileStatement class]]){
        result = [self convertDoWhileStatement:(ORDoWhileStatement *) node];
    }else if ([node isKindOfClass:[ORSwitchStatement class]]) {
        result = [self convertSwitchStatement:(ORSwitchStatement *) node];
    } else if ([node isKindOfClass:[ORForStatement class]]) {
        result = [self convertForStatement:(ORForStatement *) node];
    } else if ([node isKindOfClass:[ORForInStatement class]]) {
        result = [self convertForInStatement:(ORForInStatement *) node];
    }else if ([node isKindOfClass:[ORClassNode class]]) {
        result = [self convertOCClass:(ORClassNode *)node];
    }
    if (node.withSemicolon == YES) {
        result = [result stringByAppendingString:@";"];
    }
    return result;
}
- (NSString *)convertOCClass:(ORClassNode *)occlass{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"class %@:%@",occlass.className,occlass.superClassName];
    if (occlass.protocols.count > 0) {
        [content appendFormat:@"<%@>",[occlass.protocols componentsJoinedByString:@","]];
    }
    [content appendString:@"{\n"];
    for (ORPropertyNode *prop in occlass.properties) {
        [content appendString:[self convertPropertyDeclare:prop]];
    }
    for (ORMethodNode *imp in occlass.methods) {
        [content appendString:[self convertMethodImp:imp]];
    }
    [content appendString:@"\n}\n"];
    return content;
}

- (NSString *)convertTypeNode:(ORTypeNode *)typeSpecial{
    if (typeSpecial == nil) {
        return @"void ";
    }
    NSMutableString *result = [NSMutableString string];
    switch (typeSpecial.type){
        case OCTypeUChar:
        case OCTypeUShort:
        case OCTypeUInt:
        case OCTypeULong:
        case OCTypeULongLong:
            [result appendString:@"uint"]; break;
        case OCTypeChar:
        case OCTypeShort:
        case OCTypeInt:
        case OCTypeLong:
        case OCTypeLongLong:
            [result appendString:@"int"]; break;
        case OCTypeDouble:
        case OCTypeFloat:
            [result appendString:@"double"]; break;
        case OCTypeVoid:
            [result appendString:@"void"]; break;
        case OCTypeSEL:
            [result appendString:@"SEL"]; break;
        case OCTypeClass:
            [result appendString:@"Class"]; break;
        case OCTypeBOOL:
            [result appendString:@"BOOL"]; break;
        case OCTypeObject:
            [result appendString:typeSpecial.name]; break;
            
        case OCTypeStruct:
            [result appendString:typeSpecial.name]; break;
            break;
        default:
            [result appendString:@"UnKnownType"];
            break;
    }
    [result appendString:@" "];
    
    return result;
}

- (NSString *)convertPropertyDeclare:(ORPropertyNode *)propertyDecl{
    
    return [NSString stringWithFormat:@"@property(%@)%@;\n",[propertyDecl.keywords componentsJoinedByString:@","],[self convertDeclaratorNode:propertyDecl.var]];
    return @"";
}
- (NSString *)convertMethoDeclare:(ORMethodDeclNode *)methodDecl{
    NSString *methodName = @"";
    if (methodDecl.parameterNames.count == 0) {
        methodName = methodDecl.methodNames.firstObject;
    }else{
        NSMutableArray *list = [NSMutableArray array];
        for (int i = 0; i < methodDecl.parameterNames.count; i++) {
            [list addObject:[NSString stringWithFormat:@"%@:(%@)%@",
                             methodDecl.methodNames[i],
                             [self convertDeclaratorNode:methodDecl.parameterTypes[i]],
                             methodDecl.parameterNames[i]]];
        }
        methodName = [list componentsJoinedByString:@" "];
    }
    return [NSString stringWithFormat:@"%@(%@)%@",methodDecl.isClassMethod?@"+":@"-",[self convertDeclaratorNode:methodDecl.returnType],methodName];
}
- (NSString *)convertMethodImp:(ORMethodNode *)methodImp{
    return [NSString stringWithFormat:@"\n%@%@",[self convertMethoDeclare:methodImp.declare],[self convertScopeImp:methodImp.scopeImp]];
}
int indentationCont = 0;
- (NSString *)convertScopeImp:(ORBlockNode *)imp{
    NSMutableString *content = [NSMutableString string];
    indentationCont++;
    [content appendString:@"{\n"];
    NSMutableString *tabs = [@"" mutableCopy];
    for (int i = 0; i < indentationCont - 1; i++) {
        [tabs appendString:@"    "];
    }
    for (id statement in imp.statements) {
        if ([statement isKindOfClass:[ORNode class]]) {
            [content appendFormat:@"%@    %@\n",tabs,[self convert:statement]];
        }
    }
    [content appendFormat:@"%@}",tabs];
    indentationCont--;
    return content;
}
- (NSString *)convertBlockImp:(ORFunctionNode *)imp{
    NSMutableString *content = [NSMutableString string];
    if (imp.declare) {
        if (!imp.declare.var.isBlock) {
            // void x(int y){ }
            [content appendFormat:@"%@", [self convertDeclaratorNode:imp.declare]];
        }else{
            // ^void (int x){ }
            [content appendFormat:@"^%@", [self convertDeclaratorNode:imp.declare]];
        }
    }
    [content appendString:[self convertScopeImp:imp.scopeImp]];
    return content;
}
- (NSString *)convertBinaryExp:(ORBinaryNode *)exp{
    NSString *operator = @"";
    switch (exp.operatorType) {
        case BinaryOperatorAdd:
            operator = @"+";
            break;
        case BinaryOperatorSub:
            operator = @"-";
            break;
        case BinaryOperatorDiv:
            operator = @"/";
            break;
        case BinaryOperatorMulti:
            operator = @"*";
            break;
        case BinaryOperatorMod:
            operator = @"%";
            break;
        case BinaryOperatorShiftLeft:
            operator = @"<<";
            break;
        case BinaryOperatorShiftRight:
            operator = @">>";
            break;
        case BinaryOperatorAnd:
            operator = @"&";
            break;
        case BinaryOperatorOr:
            operator = @"|";
            break;
        case BinaryOperatorXor:
            operator = @"^";
            break;
        case BinaryOperatorLT:
            operator = @"<";
            break;
        case BinaryOperatorGT:
            operator = @">";
            break;
        case BinaryOperatorLE:
            operator = @"<=";
            break;
        case BinaryOperatorGE:
            operator = @">=";
            break;
        case BinaryOperatorNotEqual:
            operator = @"!=";
            break;
        case BinaryOperatorEqual:
            operator = @"==";
            break;
        case BinaryOperatorLOGIC_AND:
            operator = @"&&";
            break;
        case BinaryOperatorLOGIC_OR:
            operator = @"||";
            break;
    }
    return [NSString stringWithFormat:@"%@ %@ %@",[self convert:exp.left],operator,[self convert:exp.right]];
}
- (NSString *)convertUnaryExp:(ORUnaryNode *)exp{
    NSString *format = @"%@";
    switch (exp.operatorType) {
            
        case UnaryOperatorIncrementSuffix:
            format = @"%@++";
            break;
        case UnaryOperatorDecrementSuffix:
            format = @"%@--";
            break;
        case UnaryOperatorIncrementPrefix:
            format = @"++%@";
            break;
        case UnaryOperatorDecrementPrefix:
            format = @"--%@";
            break;
        case UnaryOperatorNot:
            format = @"!%@";
            break;
        case UnaryOperatorNegative:
            format = @"-%@";
            break;
        case UnaryOperatorBiteNot:
            format = @"-%@";
            break;
        case UnaryOperatorSizeOf:
            format = @"~%@";
            break;
        case UnaryOperatorAdressPoint:
            format = @"&%@";
            break;
        case UnaryOperatorAdressValue:
            format = @"*%@";
            break;
    }
    return [NSString stringWithFormat:format,[self convert:exp.value]];
}
- (NSString *)convertTernaryExp:(ORTernaryNode *)exp{
    if (exp.values.count == 1) {
        return [NSString stringWithFormat:@"%@ ?: %@",[self convert:exp.expression],[self convert:exp.values.firstObject]];
    }else{
        return [NSString stringWithFormat:@"%@ ? %@ : %@",[self convert:exp.expression],[self convert:exp.values.firstObject],[self convert:exp.values.lastObject]];
    }
}
- (NSString *)convertInitDeclareExp:(ORInitDeclaratorNode *)exp{
    if (exp.expression) {
        NSMutableString *str = [NSMutableString string];
        is_left_value = true;
        [str appendString:[self convertDeclaratorNode:exp.declarator]];
        is_left_value = false;
        [str appendString:@" = "];
        
        [str appendString:[self convert:exp.expression]];
        
        return str;
    }else{
        return [NSString stringWithFormat:@"%@",[self convertDeclaratorNode:exp.declarator]];
    }
    return @"";
}
- (NSString *)convertAssginExp:(ORAssignNode *)exp{
    NSMutableString *str = [NSMutableString string];
    is_left_value = true;
    [str appendString:[self convert:exp.value]];
    is_left_value = false;
    [str appendString:@" = "];
    [str appendString:[self convert:exp.expression]];
    return str;
}
- (NSString *)convertORIntegerValue:(ORIntegerValue *)value{
    return [NSString stringWithFormat:@"%lld",value.value];
}
- (NSString *)convertORUIntegerValue:(ORUIntegerValue *)value{
    return [NSString stringWithFormat:@"%llu",value.value];
}
- (NSString *)convertORDoubleValue:(ORDoubleValue *)value{
    return [NSString stringWithFormat:@"%f",value.value];
}
- (NSString *)convertORBoolValue:(ORBoolValue *)value{
    return [NSString stringWithFormat:@"%@",value.value ? @"YES" : @"NO"];
}
- (NSString *)convertOCValue:(ORValueNode *)value{
    switch (value.value_type){
        case OCValueSelector:
            return [NSString stringWithFormat:@"@selector(%@)",value.value];
        case OCValueVariable:
            return value.value;
        case OCValueSelf:
            return @"self";
        case OCValueSuper:
            return @"super";
            
        case OCValueString:
            return [NSString stringWithFormat:@"@\"%@\"",value.value?:@""];
        case OCValueCString:
            return [NSString stringWithFormat:@"\"%@\"",value.value?:@""];
        case OCValueProtocol:
            return [NSString stringWithFormat:@"@protocol(%@)",value.value];
        case OCValueDictionary:
        {
            NSMutableArray <NSMutableArray *>*keyValuePairs = value.value;
            NSMutableArray *pairs = [NSMutableArray array];
            for (NSMutableArray *keyValue in keyValuePairs) {
                [pairs addObject:[NSString stringWithFormat:@"%@:%@",[self convert:keyValue[0]],[self convert:keyValue[1]]]];
            }
            return [NSString stringWithFormat:@"@{%@}",[pairs componentsJoinedByString:@","]];
        }
        case OCValueArray:{
            NSMutableArray *exps = value.value;
            NSMutableArray *elements = [NSMutableArray array];
            for (ORNode * exp in exps) {
                [elements addObject:[self convert:exp]];
            }
            return [NSString stringWithFormat:@"@[%@]",[elements componentsJoinedByString:@","]];
        }
        case OCValueNSNumber:{
            if ([value.value isKindOfClass:[NSString class]]) {
                return [NSString stringWithFormat:@"@(%@)",value.value];
            }
            if ([value.value isKindOfClass:[ORNode class]]) {
                return [NSString stringWithFormat:@"@(%@)",[self convert:value.value]];
            }
        }
        case OCValueNil:
            return @"nil";
        case OCValueNULL:
            return @"NULL";
    }
    return @"";
}
- (NSString *)convertSubscript:(ORSubscriptNode *)collection{
    return [NSString stringWithFormat:@"%@[%@]",[self convert:collection.caller],[self convert:collection.keyExp]];
}
- (NSString *)convertFunCall:(ORFunctionCall *)call{
    // FIX: make.left.equalTo(superview.mas_left) to make.left.equalTo()(superview.mas_left)
    // FIX: x.left(a) to x.left()(a)
    if ([call.caller isKindOfClass:[ORMethodCall class]] && [(ORMethodCall *)call.caller methodOperator]){
        return [NSString stringWithFormat:@"%@()(%@)",[self convert:call.caller],[self convertExpressionList:call.expressions]];
    }
    return [NSString stringWithFormat:@"%@(%@)",[self convert:call.caller],[self convertExpressionList:call.expressions]];
}
- (NSString *)convertOCMethodCall:(ORMethodCall *)call{
    NSMutableString *methodName = [[call.names componentsJoinedByString:@":"] mutableCopy];
    NSString *sel;
    if (call.values.count == 0) {
        if (call.methodOperator) {
            sel = [NSString stringWithFormat:@".%@",methodName];
        }else{
            sel = [NSString stringWithFormat:@".%@()",methodName];
        }
    }else{
        sel = [NSString stringWithFormat:@".%@:(%@)",methodName,[self convertExpressionList:call.values]];
    }
    return [NSString stringWithFormat:@"%@%@",[self convert:call.caller],sel];
}
- (NSString *)convertIfStatement:(ORIfStatement *)statement{
    NSString *content = @"";
    while (statement.last) {
        if (!statement.condition) {
            content = [NSString stringWithFormat:@"%@else%@",content,[self convertScopeImp:statement.scopeImp]];
        }else{
            content = [NSString stringWithFormat:@"else if(%@)%@%@",[self convert:statement.condition],[self convertScopeImp:statement.scopeImp],content];
        }
        statement = statement.last;
    }
    content = [NSString stringWithFormat:@"if(%@)%@%@",[self convert:statement.condition],[self convertScopeImp:statement.scopeImp],content];
    return content;
}
- (NSString *)convertWhileStatement:(ORWhileStatement *)statement{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"while(%@)",[self convert:statement.condition]];
    [content appendString:[self convertScopeImp:statement.scopeImp]];
    return content;
}
- (NSString *)convertDoWhileStatement:(ORDoWhileStatement *)statement{
    return [NSString stringWithFormat:@"do%@while(%@)",[self convertScopeImp:statement.scopeImp],[self convert:statement.condition]];
}
- (NSString *)convertSwitchStatement:(ORSwitchStatement *)statement{
    return [NSString stringWithFormat:@"switch(%@){\n%@}",[self convert:statement.value],[self convertCaseStatements:statement.cases]];
}
- (NSString *)convertCaseStatements:(NSArray *)cases{
    NSMutableString *content = [NSMutableString string];
    for (ORCaseStatement *statement in cases) {
        if (statement.value) {
            [content appendFormat:@"case %@:%@\n",[self convert:statement.value],[self convertScopeImp:statement.scopeImp]];
        }else{
            [content appendFormat:@"default:%@\n",[self convertScopeImp:statement.scopeImp]];
        }
    }
    return content;
}
- (NSString *)convertForStatement:(ORForStatement *)statement{
    NSMutableString *content = [@"for (" mutableCopy];
    [content appendFormat:@"%@; ",[self convertExpressionList:statement.varExpressions]];
    [content appendFormat:@"%@; ",[self convert:statement.condition]];
    [content appendFormat:@"%@)",[self convertExpressionList:statement.expressions]];
    [content appendFormat:@"%@",[self convertScopeImp:statement.scopeImp]];
    return content;
}
- (NSString *)convertForInStatement:(ORForInStatement *)statement{
    return [NSString stringWithFormat:@"for (%@ in %@)%@",[self convert:statement.expression],[self convert:statement.value],[self convertScopeImp:statement.scopeImp]];
}
- (NSString *)convertControlStatement:(ORControlStatNode *)statement{
    switch (statement.type) {
        case ORControlStatBreak:
            return @"break";
        case ORControlStatContinue:
            return @"continue";
        case ORControlStatReturn:
            return [NSString stringWithFormat:@"return %@",[self convert:statement.expression]];
        default:
            break;
    }
    return @"";
}
- (NSString *)convertBreakStatement:(ORControlStatNode *) statement{
    return @"break";
}
- (NSString *)convertContinueStatement:(ORControlStatNode *) statement{
    return @"continue";
}
- (NSString * )convertExpressionList:(NSArray *)list{    
    NSMutableArray *array = [NSMutableArray array];
    for (ORNode * exp in list){
        [array addObject:[self convert:exp]];
    }
    return [array componentsJoinedByString:@","];
}
- (NSString *)convertVariable:(ORVariableNode *)var{
    NSMutableString *result = [@"" mutableCopy];
    for (int i = 0; i < var.ptCount; i++) {
        [result appendString:@"*"];
    }
    if (var.varname){
        [result appendString:var.varname];
    }
    return result;
}
- (NSString *)convertTypeVarPair:(ORDeclaratorNode *)pair{
    NSString *type = pair.type ? [self convertTypeNode:pair.type] : @"void ";
    return [NSString stringWithFormat:@"%@%@",type,[self convertVariable:pair.var]];
}
- (NSString *)convertDeclaratorNode:(ORDeclaratorNode *)pair{
    if ([pair isKindOfClass:[ORFunctionDeclNode class]]){
        ORFunctionDeclNode *funVar = (ORFunctionDeclNode *)pair;
        if (is_left_value && pair.var.isBlock){
            if (pair.var.varname == nil) {
                return @"Block";
            }
            return [NSString stringWithFormat:@"Block %@", pair.var.varname];
//            else{
//                return [NSString stringWithFormat:@"Point %@", pair.var.varname];
//            }
        }else{
            NSMutableString *result = [@"" mutableCopy];
            if (funVar.params.count > 0){
                [result appendFormat:@"%@%@(%@)",[self convertTypeNode:funVar.type],[self convertVariable:funVar.var],[self convertDeclaratorNodes:funVar.params]];
            } else if (!funVar.var.isBlock){
                [result appendFormat:@"%@%@()",[self convertTypeNode:funVar.type],[self convertVariable:funVar.var]];
            } else if (funVar.var.isBlock){
                [result appendFormat:@"%@%@",[self convertTypeNode:funVar.type],[self convertVariable:funVar.var]];
            }
            return result;
        }
    }
    switch (pair.type.type){
        case OCTypeUChar:
        case OCTypeUShort:
        case OCTypeUInt:
        case OCTypeULong:
        case OCTypeULongLong:
        case OCTypeChar:
        case OCTypeShort:
        case OCTypeInt:
        case OCTypeLong:
        case OCTypeFloat:
        case OCTypeDouble:
        case OCTypeBOOL:
        case OCTypeLongLong:{
            if (pair.var.ptCount > 0){
                return [NSString stringWithFormat:@"Point %@",pair.var.varname];
            }
            break;
        }
        default:
            break;
    }
    return [self convertTypeVarPair:pair];
}
- (NSString *)convertDeclaratorNodes:(NSArray *)list{
    NSMutableArray *array = [NSMutableArray array];
    for (ORDeclaratorNode * pair in list){
        [array addObject:[self convertDeclaratorNode:pair]];
    }
    return [array componentsJoinedByString:@","];
}
@end
