{
  const stripIndent = require('strip-indent')
  const fromEntries = Object.fromEntries ||  ((iterable) => {
    return [...iterable].reduce((obj, [key, val]) => {
      obj[key] = val
      return obj
    }, {})
  })

}

start = Document

SourceCharacter
  = .

LineTerminator
  = [\n\r]

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

Integer "integer"
  = _ [0-9]+ { return parseInt(text(), 10); }

Name
  = head: [_A-Za-z] tail: [_0-9A-Za-z]* { return head + tail.join('') }

Comment = "#" [^\n\r]* EOL


NamedType = Name

ListType = "["_ Type _ "]"

NonNullType
  = NamedType "!"
  / ListType "!"

Type
  = NonNullType
  / NamedType
  / ListType


Value
  = ObjectValue
  / ArrayValue
  / StringValue
  / NumberValue
  / EnumValue
  / Variable

EnumValue = Name

StringCharacter
  = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }

BlockStringCharacter "BlockStringCharactor"
  = !('"""') SourceCharacter { return text(); }

StringValue "string"
  = '"""' chars:BlockStringCharacter* '"""' {
    return stripIndent(chars.join('')).trim()
  }
  / '"' chars:StringCharacter* '"' {  return chars.join('')  }


NumberValue
  = "-"? ("0" / ([1-9] [0-9]*)) ("." [0-9]+)? (("e" / "E") ("+" / "-")? [0-9]+)? {
    return parseFloat(text())
  }


ObjectField
  = name:Name _ ":" _ value: Value  {
    return [name, value]
  }

ObjectValue
  = "{" props:(_ p:ObjectField _ { return p })*  "}" {
  	return fromEntries(props)
  }


ArrayValue
  = "[" head:(_ Value _)* "]" {
    return head.map((element) => element[1])
  }


DefaultValue
  = "=" _ Value


Variable
  = "$" Name { return text() }

VariableDefinition
  = variable:Variable ":" _ type: Type _ dflt:DefaultValue? { return { variable, type, defaultValue: dflt } }

VariableDefinitions
  = "(" vars:(_ v:VariableDefinition _ { return v })+ _ ")" { return vars }

Argument
  = _ name:Name _ ":" _ value:Value _ { return [name, value] }

Arguments
  = "(" args:(_ arg:Argument _ { return arg })* _ ")" { return fromEntries(args) }

Alias = alias:Name _ ":" { return alias }

Field
  = alias:Alias? _ name:Name _ args:Arguments? d:Directives? s:SelectionSet? {
    return { name, alias, args, s, directives: d }
  }

Selection
  = Field
  / FragmentSpread
  / InlineFragment

SelectionSet
  = "{" fields:(_ f:Selection _ { return f })* "}" {
  	return {
      kind: 'selection',
      properties: fields
    }
  }

OperationType = "query" / "mutation" / "subscription"

OperationDefinition
  = _ type:OperationType _ name:Name? _ vars:VariableDefinitions? _ d:Directives? _ s:SelectionSet {
    return {
    	operationType: type,
        name,
        variables: vars,
        directives: d,
        selection: s
    }
  }
  / _ s:SelectionSet {
    return {
    	operationType: 'query',
        selection: s
    }
  }

TypeCondition = "on" _ type:NamedType { return type }

Directive
  = "@" n:Name _ a:Arguments? { return {kind: 'Directive', name: n, args: a } }

Directives
  = (d:Directive _ { return d })*

// should exclude "on"
FragmentName = Name

FragmentDefinition
  = "fragment" _ name:FragmentName _ type:TypeCondition _ SelectionSet {
	return fragment(name, type)
  }

FragmentSpread
  = "..." _ name:FragmentName _ s:SelectionSet {
	return { kind: 'fragmentSpread', selecton: s }
  }

InlineFragment
  = "..." _ type:TypeCondition _ s:SelectionSet {
	return { kind: 'InlineSpread', type, selecton: s }
  }


// Type Def (SDL) --------------------------

Description
  = StringValue

RootOperationTypeDefinition
  = _ ot:OperationType ":" _ nt:NamedType _ { return [ot, nt ]}

RootOperationTypeDefinitions
  = "{" defs:(_ d:RootOperationTypeDefinition _ { return d })+ _ "}" {
    return fromEntries(defs)
  }

SchemaDefinition
  = _ description:Description? _ "schema" _ directives:Directives? _ def: RootOperationTypeDefinitions _ {
    return {
      kind: 'schema',
      description,
      directives,
      definitions: def
    }
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
      return {
        kind: 'scalar',
        description,
        name,
        directives
      }
    }

  UnionTypeDefinition
    = _ description:Description? _ "union" _ name:Name _ directives:Directives? _ members: UnionMemberTypes? _ {
      return { kind: 'union', description, name, directives, members }
    }

  UnionMemberTypes
    = _ "=" _ "|"? _ head:NamedType _ tail:("|" _ t:NamedType  _ { return t })+ _ {
      return [head].concat(tail)
    }

  EnumTypeDefinition
    = _ description:Description? _ "enum" _ name:Name _ directives:Directives? _ values:EnumValuesDefinition _ {
      return { kind: 'enum', description, values, directives }
    }

  EnumValuesDefinition
    = "{" defs:(_ d:EnumValueDefinition _ { return d })+ _ "}" {
      return defs
    }

  EnumValueDefinition
    = _ description:Description? _ value:EnumValue _ directives:Directives? _  {
      return { description, value, directives }
    }

  ObjectTypeDefinition
    = _ description:Description? _ "type" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition? _ {
      return { kind: 'object', description, name, impls, directives, fields: fields || [] }
    }

  InterfaceTypeDefinition
    = _ description:Description? _ "interface" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition? _ {
      return { kind: 'interface', description, name, impls, directives, fields: fields || [] }
    }

  FieldDefinition
    = _ description:Description? _ name:Name _ args:ArgumentsDefinition? _ ":" _ type:Type _ directives:Directives? _ {
      return { name, type, description, args, directives }
    }

  FieldsDefinition
    = "{" fields:(_ f:FieldDefinition _ { return f })* "}" { return fields }

  InputValueDefinition
    = _ description:Description? _ name:Name _ ":" _ type:Type _ defaultValue:DefaultValue? _ directives:Directives? _   {
      return { name, type, description, defaultValue, directives }
    }

  ArgumentsDefinition
    = "(" args:(_ arg:InputValueDefinition _ { return arg })* _ ")" { return args }

  ImplementsInterfaces
    = "implements" _ "&"? _ head:NamedType _ tail:("&" _ t:NamedType  _ { return t })* _  {
      return [head].concat(tail)
    }

  InputObjectTypeDefinition
    = _ description:Description? _ "input" _ name:Name _ directives:Directives? _ fields:InputFieldsDefinition? _ {
      return { kind: 'input', description, name, directives, fields: fields || [] }
    }

  InputFieldsDefinition
    = "{" args:(_ arg:InputValueDefinition _ { return arg })* _ "}" { return args }



DirectiveDefinition
    = _ description:Description? _ "directive" _ '@' name:Name _ args:ArgumentsDefinition _ r:'repeatable'? _ 'on' _ locations:DirectiveLocations _ {
      return { kind: 'directive', description, name, repeatable: !!r, args, locations }
    }

  DirectiveLocations
    = _ "|"? _ head:DirectiveLocation _ tail:("|" _ t:DirectiveLocation  _ { return t })* _ {
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
    = Extend "schema" _ directives:Directives? _ def: RootOperationTypeDefinitions _ {
      return {
        kind: 'schemaExtension',
        directives,
        definitions: def
      }
    }
    / Extend "schema" _ directives:Directives _ {
      return {
        kind: 'schemaExtension',
        directives,
        definitions: null
      }
    }

TypeExtension
  = ScalarTypeExtension
  / ObjectTypeExtension
  / InterfaceTypeExtension
  / UnionExtension
  / EnumExtension
  / InputObjectTypeExtension


  ScalarTypeExtension
    = Extend "scalar" _ name:Name _ directives:Directives _  { return { kind: 'scalarExtension', name, directives } }

  ObjectTypeExtension
    = Extend "type" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition _ {
      return { kind: 'objectExtension', name, impls, directives, fields }
    }
    / Extend "type" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives _ {
      return { kind: 'objectExtension', name, impls, directives, fields: [] }
    }
    / Extend "type" _ name:Name _ impls:ImplementsInterfaces _ {
      return { kind: 'objectExtension', name, impls, directives: null, fields: [] }
    }

  InterfaceTypeExtension
    = Extend "interface" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives? _ fields:FieldsDefinition _ {
      return { kind: 'interfaceExtension', name, impls, directives, fields }
    }
    / Extend "interface" _ name:Name _ impls:ImplementsInterfaces? _ directives:Directives _ {
      return { kind: 'interfaceExtension', name, impls, directives, fields: [] }
    }
    / Extend "interface" _ name:Name _ impls:ImplementsInterfaces _ {
      return { kind: 'interfaceExtension', name, impls, directives: null, fields: [] }
    }

  UnionExtension
    = Extend "union" _ name:Name _ directives:Directives? _ members:UnionMemberTypes _  {
       return { kind: 'unionExtension', name, directives, members }
    }
    / Extend "union" _ name:Name _ directives:Directives _  {
      return { kind: 'unionExtension', name, directives, members: null }
    }

  EnumExtension
    = Extend "enum" _ name:Name _ directives:Directives? _ values:EnumValuesDefinition _  {
       return { kind: 'enumExtension', name, directives, values }
    }
    / Extend "enum" _ name:Name _ directives:Directives _  {
      return { kind: 'enumExtension', name, directives, values: null }
    }

  InputObjectTypeExtension
    = Extend "input" _ name:Name _ directives:Directives? _ fields:InputFieldsDefinition _  {
       return { kind: 'inputExtension', name, directives, fields }
    }
    / Extend "input" _ name:Name _ directives:Directives _  {
      return { kind: 'inputExtension', name, directives, fields: null }
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
  = ops:(_ def:Definition _ { return def })* { return { definitions: ops } }




// Helpers --------------------------

EOW = ! [_a-zA-Z0-9]+

WS = [ \t,]
EOF = !.
EOL
 = [\n\r]{1,2}
 / EOF



_ "whitespace"
  = WS* Comment
  / [ \t\n\r,]*
