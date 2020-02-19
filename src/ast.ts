export const enum ASTKind {
  Name = 0,
  Document,
  OperationDefinition,
  VariableDefinition,
  Variable,
  SelectionSet,
  Field,
  Argument,
  FragmentSpread,
  InlineFragment,
  FragmentDefinition,
  IntValue,
  FloatValue,
  StringValue,
  BooleanValue,
  NullValue,
  EnumValue,
  ListValue,
  ObjectValue,
  ObjectField,
  Directive,
  NamedType,
  ListType,
  NonNullType,
  SchemaDefinition,
  OperationTypeDefinition,
  ScalarTypeDefinition,
  ObjectTypeDefinition,
  FieldDefinition,
  InputValueDefinition,
  InterfaceTypeDefinition,
  UnionTypeDefinition,
  EnumTypeDefinition,
  EnumValueDefinition,
  InputObjectTypeDefinition,
  DirectiveDefinition,
  SchemaExtension,
  ScalarTypeExtension,
  ObjectTypeExtension,
  InterfaceTypeExtension,
  UnionTypeExtension,
  EnumTypeExtension,
  InputObjectTypeExtension,
}

export type Bool = 0 | 1;

export type Maybe<T> = T | undefined;

export type NameNode = readonly [ASTKind.Name, string];

export type DocumentNode = readonly [
  ASTKind.Document,
  readonly DefinitionNode[],
];

export type DefinitionNode =
  | ExecutableDefinitionNode
  | TypeSystemDefinitionNode
  | TypeSystemExtensionNode;

export type ExecutableDefinitionNode =
  | OperationDefinitionNode
  | FragmentDefinitionNode;

export type OperationDefinitionNode = readonly [
  ASTKind.OperationDefinition,
  OperationType,
  Maybe<NameNode>,
  Maybe<VariableDefinitions>,
  Maybe<Directives>,
  SelectionSetNode,
];

type VariableDefinitions = readonly VariableDefinitionNode[];
type Directives = readonly DirectiveNode[];

export const enum OperationType {
  query = 0,
  mutation,
  subscription,
}

export type VariableDefinitionNode = [
  ASTKind.VariableDefinition,
  VariableNode,
  TypeNode,
  /* defaultValue */ Maybe<ValueNode>,
  Maybe<Directives>,
];

export type VariableNode = [ASTKind.Variable, NameNode];

export type SelectionSetNode = [ASTKind.SelectionSet, SelectionNode[]];

export type SelectionNode =
  | FieldNode
  | FragmentSpreadNode
  | InlineFragmentNode;

export type FieldNode = [
  ASTKind.Field,
  /* alias */ Maybe<NameNode>,
  NameNode,
  Maybe<Arguments>,
  Maybe<Directives>,
  Maybe<SelectionSetNode>,
];

export type Arguments = readonly ArgumentNode[];

export type ArgumentNode = readonly [ASTKind.Argument, NameNode, ValueNode];

export type FragmentSpreadNode = readonly [
  ASTKind.FragmentSpread,
  NameNode,
  Maybe<Directives>,
];

export type InlineFragmentNode = readonly [
  ASTKind.InlineFragment,
  Maybe<NamedTypeNode>,
  Maybe<Directives>,
  SelectionSetNode,
];

export type FragmentDefinitionNode = readonly [
  ASTKind.FragmentDefinition,
  NameNode,
  /* variableDefinitions */ null,
  NamedTypeNode,
  Maybe<Directives>,
  SelectionSetNode,
];

export type ValueNode =
  | VariableNode
  | IntValueNode
  | FloatValueNode
  | StringValueNode
  | BooleanValueNode
  | NullValueNode
  | EnumValueNode
  | ListValueNode
  | ObjectValueNode;

export type IntValueNode = readonly [ASTKind.IntValue, number];

export type FloatValueNode = readonly [ASTKind.FloatValue, number];

export type BooleanValueNode = readonly [ASTKind.BooleanValue, boolean];

export type NullValueNode = readonly [ASTKind.NullValue];

export type StringValueNode = readonly [ASTKind.StringValue, string];

export type EnumValueNode = readonly [ASTKind.EnumValue, string];

export type ListValueNode = readonly [ASTKind.ListValue, readonly ValueNode[]];

export type ObjectValueNode = readonly [
  ASTKind.ObjectValue,
  readonly ObjectFieldNode[],
];

export type ObjectFieldNode = readonly [
  ASTKind.ObjectField,
  NameNode,
  ValueNode,
];

export type DirectiveNode = readonly [
  ASTKind.Directive,
  NameNode,
  Maybe<Arguments>,
];

export type TypeNode = NamedTypeNode | ListTypeNode;

export type NamedTypeNode = readonly [
  ASTKind.NamedType,
  NameNode,
  /* non null */ Bool,
];

export type ListTypeNode = readonly [ASTKind.ListType, TypeNode];

// Type System Definition

export type Description = Maybe<StringValueNode>;

export type TypeSystemDefinitionNode =
  | SchemaDefinitionNode
  | TypeDefinitionNode
  | DirectiveDefinitionNode;

export type SchemaDefinitionNode = readonly [
  ASTKind.SchemaDefinition,
  Description,
  Maybe<Directives>,
  readonly OperationTypeDefinitionNode[],
];

export type OperationTypeDefinitionNode = readonly [
  ASTKind.OperationTypeDefinition,
  OperationType,
  NamedTypeNode,
];

// Type Definition

export type TypeDefinitionNode =
  | ScalarTypeDefinitionNode
  | ObjectTypeDefinitionNode
  | InterfaceTypeDefinitionNode
  | UnionTypeDefinitionNode
  | EnumTypeDefinitionNode
  | InputObjectTypeDefinitionNode;

export type ScalarTypeDefinitionNode = [
  ASTKind.ScalarTypeDefinition,
  Description,
  NameNode,
  Maybe<Directives>,
];

export type Interfaces = readonly NamedTypeNode[];

export type ObjectTypeDefinitionNode = [
  ASTKind.ObjectTypeDefinition,
  Description,
  NameNode,
  Maybe<Interfaces>,
  Maybe<Directives>,
  Maybe<readonly FieldDefinitionNode[]>,
];

export type FieldDefinitionNode = [
  ASTKind.FieldDefinition,
  Description,
  NameNode,
  Maybe<Arguments>,
  TypeNode,
  Maybe<Directives>,
];

export type InputValueDefinitionNode = [
  ASTKind.InputValueDefinition,
  Description,
  NameNode,
  TypeNode,
  /* defaultValue */ Maybe<ValueNode>,
  Maybe<Directives>,
];

export type InterfaceTypeDefinitionNode = [
  ASTKind.InterfaceTypeDefinition,
  Description,
  NameNode,
  Maybe<Interfaces>,
  Maybe<Directives>,
  Maybe<readonly FieldDefinitionNode[]>,
];

export type UnionTypeDefinitionNode = [
  ASTKind.UnionTypeDefinition,
  Description,
  NameNode,
  Maybe<Directives>,
  /* types */ Maybe<readonly NamedTypeNode[]>,
];

export type EnumTypeDefinitionNode = [
  ASTKind.EnumTypeDefinition,
  Description,
  NameNode,
  Maybe<Directives>,
  /* values */ Maybe<readonly EnumValueDefinitionNode[]>,
];

export type EnumValueDefinitionNode = [
  ASTKind.EnumValueDefinition,
  Description,
  NameNode,
  Maybe<Directives>,
];

export type InputObjectTypeDefinitionNode = [
  ASTKind.InputObjectTypeDefinition,
  Description,
  NameNode,
  Maybe<Directives>,
  Maybe<readonly FieldDefinitionNode[]>,
];

export type DirectiveDefinitionNode = [
  ASTKind.DirectiveDefinition,
  Description,
  NameNode,
  Maybe<Arguments>,
  /* repeatable */ Bool,
  /* locations */ Maybe<readonly NameNode[]>,
];

// Type System Extensions

export type TypeSystemExtensionNode = SchemaExtensionNode | TypeExtensionNode;

export type SchemaExtensionNode = [
  ASTKind.SchemaExtension,
  Maybe<Directives>,
  Maybe<readonly OperationTypeDefinitionNode[]>,
];

// Type Extensions

export type TypeExtensionNode =
  | ScalarTypeExtensionNode
  | ObjectTypeExtensionNode
  | InterfaceTypeExtensionNode
  | UnionTypeExtensionNode
  | EnumTypeExtensionNode
  | InputObjectTypeExtensionNode;

export type ScalarTypeExtensionNode = [
  ASTKind.ScalarTypeExtension,
  NameNode,
  Maybe<Directives>,
];

export type ObjectTypeExtensionNode = [
  ASTKind.ObjectTypeExtension,
  NameNode,
  Maybe<Interfaces>,
  Maybe<Directives>,
  Maybe<readonly FieldDefinitionNode[]>,
];

export type InterfaceTypeExtensionNode = [
  ASTKind.InterfaceTypeExtension,
  NameNode,
  Maybe<Interfaces>,
  Maybe<Directives>,
  Maybe<readonly FieldDefinitionNode[]>,
];

export type UnionTypeExtensionNode = [
  ASTKind.UnionTypeExtension,
  NameNode,
  Maybe<Directives>,
  Maybe<readonly NamedTypeNode[]>,
];

export type EnumTypeExtensionNode = [
  ASTKind.EnumTypeExtension,
  NameNode,
  Maybe<Directives>,
  /* values */ Maybe<readonly EnumValueDefinitionNode[]>,
];

export type InputObjectTypeExtensionNode = [
  ASTKind.InputObjectTypeExtension,
  NameNode,
  Maybe<Directives>,
  Maybe<readonly FieldDefinitionNode[]>,
];

export type ASTNode =
  | NameNode
  | DocumentNode
  | OperationDefinitionNode
  | VariableDefinitionNode
  | VariableNode
  | SelectionSetNode
  | FieldNode
  | ArgumentNode
  | FragmentSpreadNode
  | InlineFragmentNode
  | FragmentDefinitionNode
  | IntValueNode
  | FloatValueNode
  | StringValueNode
  | BooleanValueNode
  | NullValueNode
  | EnumValueNode
  | ListValueNode
  | ObjectValueNode
  | ObjectFieldNode
  | DirectiveNode
  | NamedTypeNode
  | ListTypeNode
  // | NonNullTypeNode
  | SchemaDefinitionNode
  | OperationTypeDefinitionNode
  | ScalarTypeDefinitionNode
  | ObjectTypeDefinitionNode
  | FieldDefinitionNode
  | InputValueDefinitionNode
  | InterfaceTypeDefinitionNode
  | UnionTypeDefinitionNode
  | EnumTypeDefinitionNode
  | EnumValueDefinitionNode
  | InputObjectTypeDefinitionNode
  | DirectiveDefinitionNode
  | SchemaExtensionNode
  | ScalarTypeExtensionNode
  | ObjectTypeExtensionNode
  | InterfaceTypeExtensionNode
  | UnionTypeExtensionNode
  | EnumTypeExtensionNode
  | InputObjectTypeExtensionNode;

export const node = (kind: ASTKind, ...args: any[]) => [kind].concat(args);

// const t = node(ASTKind.StringValue, true);
