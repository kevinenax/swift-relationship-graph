module.exports =
  Key:
    Substructure: 'key.substructure'
    Kind: 'key.kind'
    InheritedTypes: 'key.inheritedtypes'
    Name: 'key.name'
    Definition: 'key.parsed_declaration'
    Access: 'key.accessibility'
    SetterAccess: 'key.setter_accessibility'

  DeclarationType:
    SwiftExtension: 'source.lang.swift.decl.extension'
    SwiftProtocol: 'source.lang.swift.decl.protocol'
    SwiftStruct: 'source.lang.swift.decl.struct'
    SwiftClass: 'source.lang.swift.decl.class'
    SwiftSubscript: 'source.lang.swift.decl.function.subscript'
    SwiftInstanceMethod: 'source.lang.swift.decl.function.method.instance'
    SwiftStaticMethod: 'source.lang.swift.decl.function.method.static'
    SwiftStaticVariable: 'source.lang.swift.decl.var.static'
    SwiftInstanceVariable: 'source.lang.swift.decl.var.instance'
    ObjCProtocol: 'sourcekitten.source.lang.objc.decl.protocol'
    ObjCStruct: 'sourcekitten.source.lang.objc.decl.struct'
    ObjCClass: 'sourcekitten.source.lang.objc.decl.class'

  DeclarationAccess:
      SwiftPublic: 'source.lang.swift.accessibility.public'
      SwiftInternal: 'source.lang.swift.accessibility.internal'
      SwiftPrivate: 'source.lang.swift.accessibility.private'
      SwiftFilePrivate: 'source.lang.swift.accessibility.fileprivate'
      
      
  SupportedTypes:
    Protocols: 'protocols'
    Structs: 'structs'
    Classes: 'classes'

  SupportedSubTypes:
     Functions: 'functions'
     Variables: 'variables'

  Style:
    Protocols:
      Color: 'blue'
      Shape: 'record'
    Structs:
      Color: 'red'
      Shape: 'record'
    Classes:
      Color: 'green'
      Shape: 'record'
    System:
      Color: 'black'
      Shape: 'oval'
