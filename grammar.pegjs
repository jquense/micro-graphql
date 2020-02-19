
start = Document

SourceCharacter
  = .

LineTerminator
  = [\n\r]

LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"

EscapeSequence
  = (EscapeCharacter / NonEscapeCharacter)
  / "u" digits:$([0-9a-f]i [0-9a-f]i [0-9a-f]i [0-9a-f]i) {
      return String.fromCharCode(parseInt(digits, 16));
    }

EscapeCharacter
  = '"'
  / "\\"
  / "/"
  / "u"
  / "b"  { return "\b"; }
  / "f"  { return "\f"; }
  / "n"  { return "\n"; }
  / "r"  { return "\r"; }
  / "t"  { return "\t"; }
  / "v"  { return "\v"; }

NonEscapeCharacter
  = !(EscapeCharacter / LineTerminator) SourceCharacter { return text(); }

// Integer "integer"
//   = _ [0-9]+ { return parseInt(text(), 10); }

NameString
  = head: [_A-Za-z] tail: [_0-9A-Za-z]* { return head + tail.join('') }


Name
  = name:NameString { return node(ASTKind.Name, name) }

Comment = "#" [^\n\r]* LineTerminatorSequence


NamedType = name:NameString n:"!"? { return node(ASTKind.NamedType, name, n ? 1 : 0)}

ListType = "["_ t:Type _ "]" n:"!"? { return node(ASTKind.ListType, t,  n ? 1 : 0) }

// NonNullType
//   = NamedType "!" {}
//   / ListType "!"

Type
  = NamedType
  / ListType


Value
  = ObjectValue
  / ListValue
  / BooleanValue
  / NullValue
  / NumberValue
  / StringValue
  / EnumValue
  / Variable


BooleanValue = value:(("true" EOW) / ("false" EOW)) {
  return node(ASTKind.BooleanValue, Boolean(value))
}

NullValue = "null" EOW { return node(ASTKind.NullValue)}

EnumValue =  !(BooleanValue / NullValue) name:NameString { return node(ASTKind.EnumValue, name)}

StringCharacter
  = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }

BlockStringCharacter "BlockStringCharactor"
  = !('"""' / "\\") SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }

StringValue "string"
  = '"""' chars:BlockStringCharacter* '"""' {
    return node(ASTKind.StringValue, stripIndent(chars.join('')).trim())
  }
  / '"' chars:StringCharacter* '"' {  return node(ASTKind.StringValue, chars.join(''))  }



NumberValue
  = "-"? ("0" / ([1-9] [0-9]*)) frac:("." [0-9]+)? (("e" / "E") ("+" / "-")? [0-9]+)? {
    return frac != null ?
      node(ASTKind.FloatValue, parseFloat(text())) :
      node(ASTKind.IntValue, parseInt(text(), 10))
  }


ObjectField
  = name:Name _ ":" _ value: Value  {
    return node(ASTKind.ObjectField, name, value)
  }

ObjectValue
  = "{" values:(_ p:ObjectField _ { return p })*  "}" {
  	return node(ASTKind.ObjectField, values)
  }


ListValue
  = "[" values:(_ v:Value _  { return v })* "]" {
    return node(ASTKind.ListValue, values)
  }


DefaultValue
  = "=" _ v:Value { return v }


Variable
  = "$" n:NameString { return node(ASTKind.Variable, n) }

VariableDefinition
  = variable:Variable ":" _ type: Type _ dflt:DefaultValue? {
    return node(ASTKind.VariableDefinition, variable, type, dflt)
  }

VariableDefinitions
  = "(" vars:(_ v:VariableDefinition _ { return v })+ _ ")" { return vars }

Argument
  = _ name:Name _ ":" _ value:Value _ { return node(ASTKind.Argument, name, value) }

Arguments
  = "(" args:(_ arg:Argument _ { return arg })* _ ")" { return args }

Alias = alias:Name _ ":" { return alias }

Field
  = alias:Alias? _ name:Name _ args:Arguments? _ d:Directives? _ s:SelectionSet? {
    return node(ASTKind.Field, alias, name, args, d, s)
  }

Selection
  = Field
  / InlineFragment
  / FragmentSpread

SelectionSet
  = "{" fields:(_ f:Selection _ { return f })* "}" {
  	return node(ASTKind.SelectionSet, fields)
  }

OperationType
  = "query" { return OperationType.query }
  / "mutation" { return OperationType.mutation }
  / "subscription" { return OperationType.subscription }

OperationDefinition
  = _ type:OperationType _ name:Name? _ vars:VariableDefinitions? _ d:Directives? _ s:SelectionSet {
    return node(ASTKind.OperationDefinition, type, name, vars, d, s)
  }
  / _ s:SelectionSet {
    return node(ASTKind.OperationDefinition, OperationType.query, null, null, null, s)
  }

TypeCondition = "on" _ type:NamedType { return type }

Directive
  = "@" n:Name _ a:Arguments? { return node(ASTKind.Directive, n, a) }

Directives
  = (d:Directive _ { return d })*

// should exclude "on"
FragmentName = Name

FragmentDefinition
  = "fragment" _ name:FragmentName _ type:TypeCondition _ d:Directives? _ s:SelectionSet {
	return node(ASTKind.FragmentDefinition, name, null, type, d, s)
  }

FragmentSpread
  = "..." _ name:FragmentName _ d:Directives? {
	  return node(ASTKind.FragmentSpread, name, d)
  }


InlineFragment
  = "..." _ type:TypeCondition? _ d:Directives? _ s:SelectionSet {
	  return node(ASTKind.InlineFragment, type, d, s)
  }


// Type Def (SDL) --------------------------

Description
  = StringValue

RootOperationTypeDefinition
  = _ ot:OperationType ":" _ nt:NamedType _ {
    return node(ASTKind.OperationTypeDefinition, ot, nt)
  }

RootOperationTypeDefinitions
  = "{" defs:(_ d:RootOperationTypeDefinition _ { return d })+ _ "}" {
    return defs
  }

SchemaDefinition
  = _ description:Description? _ "schema" _ directives:Directives? _ defs: RootOperationTypeDefinitions _ {
    return node(ASTKind.SchemaDefinition, description, directives, defs)
  }

TypeDefinition
  = ScalarTypeDefinition
  / ObjectTypeDefinition
  / InterfaceTypeDefinition
  / UnionTypeDefinition
  / EnumTypeDefinition
  / InputObjectTypeDefinition

  ScalarTypeDefinition
    = _ description:Description? _ "scalar" _ name:Name _ directives:Directives? _   {
      node(ASTKind.ScalarTypeDefinition, description, name, directives)
    }

  UnionTypeDefinition
    = _ description:Description? _ "union" _ name:Name _ directives:Directives? _ members: UnionMemberTypes? _ {
      return node(ASTKind.UnionTypeDefinition, description, name, directives, members)
    }

  MemberTail = "|" _ t:NamedType  _  { return t }
  UnionMemberTypes
    = _ "=" _ "|"? _ head:NamedType _ tail:MemberTail+ _ {
      return [head].concat(tail)
    }

  EnumTypeDefinition
    = _ description:Description? _ "enum" _ name:Name _ directives:Directives? _ values:EnumValuesDefinition _ {
      return node(ASTKind.EnumTypeDefinition, description, name, directives, values)
    }

  EnumValuesDefinition
    = "{" defs:(_ d:EnumValueDefinition _ { return d })+ _ "}" {
      return defs
    }

  EnumValueDefinition
    = _ description:Description? _ name:Name _ directives:Directives? _  {
      return node(ASTKind.EnumValueDefinition, description, name, directives)
    }

  ObjectTypeDefinition
    = _ description:Description? _ "type" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition? _ {
      return node(ASTKind.ObjectTypeDefinition, description, name, impls, directives, fields)
    }

  InterfaceTypeDefinition
    = _ description:Description? _ "interface" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition? _ {
      return node(ASTKind.InterfaceTypeDefinition, description, name, impls, directives, fields)
    }

  FieldDefinition
    = _ description:Description? _ name:Name _ args:ArgumentsDefinition? _ ":" _ type:Type _ directives:Directives? _ {
      return node(ASTKind.FieldDefinition, description, name, args, type, directives)
    }

  FieldsDefinition
    = "{" fields:(_ f:FieldDefinition _ { return f })* "}" { return fields }

  InputValueDefinition
    = _ description:Description? _ name:Name _ ":" _ type:Type _ defaultValue:DefaultValue? _ directives:Directives? _   {
      return node(ASTKind.InputValueDefinition, description, name, type, defaultValue, directives)
    }

  ArgumentsDefinition
    = "(" args:(_ arg:InputValueDefinition _ { return arg })* _ ")" { return args }

  ImplsTail = "&" _ t:NamedType  _ { return t }
  ImplementsInterfaces
    = "implements" _ "&"? _ head:NamedType _ tail:ImplsTail* _  {
      return [head].concat(tail)
    }

  InputObjectTypeDefinition
    = _ description:Description? _ "input" _ name:Name _ directives:Directives? _ fields:InputFieldsDefinition? _ {
      return node(ASTKind.InputObjectTypeDefinition, description, name, directives, fields)
    }

  InputFieldsDefinition
    = "{" args:(_ arg:InputValueDefinition _ { return arg })* _ "}" { return args }



DirectiveDefinition
    = _ description:Description? _ "directive" _ '@' name:Name _ args:ArgumentsDefinition _ r:'repeatable'? _ 'on' _ locations:DirectiveLocations _ {
      return node(ASTKind.DirectiveDefinition, description, name, args, r ? 1 : 0, locations)
    }

  DirectiveLocationTail
    = "|" _ t:DirectiveLocation  _ { return t }

  DirectiveLocations
    = _ "|"? _ head:DirectiveLocation _ tail:DirectiveLocationTail* _ {
      return [head].concat(tail)
    }

  DirectiveLocation
    = ExcutableDirectiveLocation
    / TypeSystemDirectiveLocation

  ExcutableDirectiveLocation
    = "QUERY" EOW
    / "MUTATION" EOW
    / "SUBSCRIPTION"
    / "FIELD" EOW
    / "FRAGMENT_DEFINITION" EOW
    / "FRAGMENT_SPREAD" EOW
    / "INLINE_FRAGMENT" EOW
    / "VARIABLE_DEFINITION" EOW

  TypeSystemDirectiveLocation
    = "SCHEMA" EOW
    / "SCALAR" EOW
    / "OBJECT" EOW
    / "FIELD_DEFINITION" EOW
    / "ARGUMENT_DEFINITION" EOW
    / "INTERFACE" EOW
    / "UNION"  EOW
    / "ENUM" EOW
    / "ENUM_VALUE" EOW
    / "INPUT_OBJECT" EOW
    / "INPUT_FIELD_DEFINITION" EOW



TypeSystemExtension
  = SchemaExtension
  / TypeExtension

  Extend = _ "extend" _

  SchemaExtension
    = Extend "schema" _ directives:Directives? _ defs: RootOperationTypeDefinitions _ {
      return node(ASTKind.SchemaExtension, directives, defs)
    }
    / Extend "schema" _ directives:Directives _ {
      return  node(ASTKind.SchemaExtension, directives, null)
    }

TypeExtension
  = ScalarTypeExtension
  / ObjectTypeExtension
  / InterfaceTypeExtension
  / UnionTypeExtension
  / EnumTypeExtension
  / InputObjectTypeExtension


  ScalarTypeExtension
    = Extend "scalar" _ name:Name _ directives:Directives _  {
      return node(ASTKind.ScalarTypeExtension, name, directives)
    }

  ObjectTypeExtension
    = Extend "type" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition _ {
      return node(ASTKind.ObjectTypeExtension, name, impls, directives, fields)
    }
    / Extend "type" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives _ {
      return node(ASTKind.ObjectTypeExtension, name, impls, directives, null)
    }
    / Extend "type" _ name:Name _ impls:ImplementsInterfaces _ {
      return node(ASTKind.ObjectTypeExtension, name, impls, null, null)
    }

  InterfaceTypeExtension
    = Extend "interface" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition _ {
      return node(ASTKind.InterfaceTypeExtension, name, impls, directives, fields)
    }
    / Extend "interface" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives _ {
      return node(ASTKind.InterfaceTypeExtension, name, impls, directives, null)
    }
    / Extend "interface" _ name:Name _ impls:ImplementsInterfaces _ {
      return node(ASTKind.InterfaceTypeExtension, name, impls, null, null)
    }

  UnionTypeExtension
    = Extend "union" _ name:Name _ directives:Directives? _ members:UnionMemberTypes _  {
      return node(ASTKind.UnionTypeExtension, name, directives, members)
    }
    / Extend "union" _ name:Name _ directives:Directives _  {
      return node(ASTKind.UnionTypeExtension, name, directives, null)
    }

  EnumTypeExtension
    = Extend "enum" _ name:Name _ directives:Directives? _ values:EnumValuesDefinition _  {
      return node(ASTKind.EnumTypeExtension, name, directives, values)
    }
    / Extend "enum" _ name:Name _ directives:Directives _  {
      return node(ASTKind.EnumTypeExtension, name, directives, null)
    }

  InputObjectTypeExtension
    = Extend "input" _ name:Name _ directives:Directives? _ fields:InputFieldsDefinition _  {
       return node(ASTKind.InputObjectTypeExtension, name, directives, fields)
    }
    / Extend "input" _ name:Name _ directives:Directives _  {
      return node(ASTKind.InputObjectTypeExtension, name, directives, null)
    }


// Document --------------------------

TypeSystemDefinition
  = SchemaDefinition
  / TypeDefinition
  / DirectiveDefinition

ExcutableDefinition
  = OperationDefinition
  / FragmentDefinition

Definition
  = ExcutableDefinition
  / TypeSystemDefinition
  / TypeSystemExtension

Document
  = ops:(_ def:Definition _ { return def })* {
    return node(ASTKind.Document, ops)
  }




// Helpers --------------------------

EOW = ! [_a-zA-Z0-9]+

WS = [ \t,]
EOF = !.



_ "whitespace"
  = WS* Comment
  / [ \t\n\r,]*
