import * as Parser from './parser';
import * as AST from './ast';

type JSONArray = JSONValue[];
interface JSONObject {
  [key: string]: JSONValue;
}

type JSONValue = string | null | number | boolean | JSONArray | JSONObject;

type Arguments = Record<string, JSONValue>;

export function parse(src: string): AST.DocumentNode {
  try {
    return Parser.parse(src);
  } catch (err) {
    if (err.location && err.location.start)
      err.message = `Line: ${err.location.start.line},${err.location.start.column}\n\n${err.message}`;
    else {
      console.log(err);
    }
    throw err;
  }
}

function generateValue(node: AST.ValueNode, vars: JSONObject): JSONValue {
  switch (node[0]) {
    case AST.ASTKind.ObjectValue:
      return Object.fromEntries(
        node[1].map(f => [f[1], generateValue(f[2], vars)]),
      );
    case AST.ASTKind.ListValue:
      return node[1].map(f => generateValue(f, vars));
    case AST.ASTKind.Variable:
      return vars[node[1][1]];
    case AST.ASTKind.NullValue:
      return null;
    default:
      return node[1];
  }
}

function generateArguments(nodes: AST.Arguments, vars: JSONObject) {
  const result: Arguments = {};

  for (const [, name, value] of nodes) {
    result[name[1]] = generateValue(value, vars);
  }
}

let id = 0;
export function buildSchema(schema: string | AST.DocumentNode) {
  const ast =
    schema[0] === AST.ASTKind.Document
      ? (schema as AST.DocumentNode)
      : parse(schema as string);

  const frags = new Map<string, AST.FragmentDefinitionNode>();
  const ops = new Map<
    AST.OperationType,
    Map<string, AST.OperationDefinitionNode>
  >();

  for (const def of ast[1] as AST.ExecutableDefinitionNode[]) {
    switch (def[0]) {
      case AST.ASTKind.FragmentDefinition:
        frags.set(def[1][1], def);
        break;
      default: {
        const m = ops.get(def[1]) || new Map();
        // should throw on multiple unnamed
        m.set(def[2] || `query`, def);
        ops.set(def[1], m);
      }
    }
  }
}
