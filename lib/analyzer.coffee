_ = require 'lodash'

Constants = require './constants.coffee'

Key = Constants.Key
DeclarationType = Constants.DeclarationType

module.exports = (json) ->

  protocols = []
  structs = []
  classes = []
  extensions = []

  protocolsAndParents = {}
  structsAndParents = {}
  classesAndParents = {}

  parseEntry = (entry) ->
    for filename, subentry of entry
      parseSubentry subentry[Key.Substructure] if subentry[Key.Substructure]

  parseSubentry = (structures) ->

    KindHandlers =
      "#{DeclarationType.SwiftProtocol}": (s) -> protocols.push s
      "#{DeclarationType.SwiftStruct}": (s) -> structs.push s
      "#{DeclarationType.SwiftClass}": (s) -> classes.push s
      "#{DeclarationType.SwiftExtension}": (s) -> extensions.push s

      #"#{DeclarationType.ObjCProtocol}": (s) -> protocols.push s
      #"#{DeclarationType.ObjCStruct}": (s) -> structs.push s
      #"#{DeclarationType.ObjCClass}": (s) -> classes.push s

    for structure in structures
      parseSubentry structure[Key.Substructure] if structure[Key.Substructure]
      KindHandlers[structure[Key.Kind]]? structure

  if _.isArray json
    for entry in json
      parseEntry entry
  else
    parseEntry json

  parseFunctions = (entity) ->
      entitySubs = entity[Key.Substructure]
      
      functions = []
      
      
      
      FunctionHandlers =
        "#{DeclarationType.SwiftSubscript}": (f) -> functions.push f
        "#{DeclarationType.SwiftInstanceMethod}": (f) -> functions.push f
        "#{DeclarationType.SwiftStaticMethod}": (f) -> functions.push f
        
      if _.isArray entitySubs 
          for structure in entitySubs
              FunctionHandlers[structure[Key.Kind]]? structure
          
      return functions
          
  parseVariables = (entity) ->
      entitySubs = entity[Key.Substructure]
      
      variables = []
      
      VariableHandlers =
        "#{DeclarationType.SwiftStaticMethod}": (f) -> variables.push f
        "#{DeclarationType.SwiftStaticVariable}": (f) -> variables.push f
        "#{DeclarationType.SwiftInstanceVariable}": (f) -> variables.push f
        
      if _.isArray entitySubs 
          for structure in entitySubs
              VariableHandlers[structure[Key.Kind]]? structure
          
      return variables
          

  parseEntity = (entity, type) ->

    TypeHandlers =
      "#{DeclarationType.SwiftProtocol}": (entity, p) -> 
          protocol =
              parents: p
              functions: parseFunctions entity
              variables: parseVariables entity
          protocolsAndParents[entity[Key.Name]] = protocol
      "#{DeclarationType.SwiftStruct}": (entity, p) -> 
          struct =
              parents: p
              functions: parseFunctions entity
              variables: parseVariables entity
          structsAndParents[entity[Key.Name]] = struct
      "#{DeclarationType.SwiftClass}": (entity, p) -> 
          klass =
              parents: p
              functions: parseFunctions entity
              variables: parseVariables entity
          classesAndParents[entity[Key.Name]] = klass
      "#{DeclarationType.SwiftExtension}": (entity, p) ->
        if classesAndParents[entity]?
          classesAndParents[entity] = _.concat classesAndParents[entity], p
        if structsAndParents[entity]?
          structsAndParents[entity] = _.concat structsAndParents[entity], p
        if protocolsAndParents[entity]?
          protocolsAndParents[entity] = _.concat protocolsAndParents[entity], p
      #"#{DeclarationType.ObjCProtocol}": (n, p) -> protocolsAndParents[n] = p
      #"#{DeclarationType.ObjCStruct}": (n, p) -> structsAndParents[n] = p
      #"#{DeclarationType.ObjCClass}": (n, p) -> classesAndParents[n] = p

    if entity[Key.InheritedTypes]?

      parents = _.map entity[Key.InheritedTypes], (entry) ->

        name = _.trim entry[Key.Name]
        match = /^([^<]*)(?:<.*>)?$/gi.exec name
        name = _.nth match, 1

        return name

    else

      parents = []

    TypeHandlers[type]? entity, parents

  for protocol in protocols
    parseEntity protocol, DeclarationType.SwiftProtocol
    #parseEntity protocol, DeclarationType.ObjCProtocol

  for struct in structs
    parseEntity struct, DeclarationType.SwiftStruct
    #parseEntity struct, DeclarationType.ObjCStruct

  for klass in classes
    parseEntity klass, DeclarationType.SwiftClass
    #parseEntity klass, DeclarationType.ObjCClass

  for extension in extensions
    parseEntity extension, DeclarationType.SwiftExtension

  analysis =
    protocols: protocolsAndParents
    structs: structsAndParents
    classes: classesAndParents

  return analysis
