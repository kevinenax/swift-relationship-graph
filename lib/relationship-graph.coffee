require 'colors'
_ = require 'lodash'
Bluebird = require 'bluebird'
fs = Bluebird.promisifyAll require 'fs'
os = require 'os'
path = require 'path'
Constants = require '../lib/constants.coffee'

availableOperations =
  dotGraphCode: (json,type,subtypes,outputFilename) ->
    console.log require('./dot-graph-code.coffee')(json, type, subtypes, outputFilename)
  dotGraphPDF: require './dot-graph-pdf.coffee'
  graph: require './dot-graph-pdf.coffee'
  dotTreeCode: (json,root,subtypes,outputFilename) ->
    console.log require('./dot-tree-code.coffee')(json, root, subtypes, outputFilename)
  dotTreePDF: require './dot-tree-pdf.coffee'
  tree: require './dot-tree-pdf.coffee'
  referenceGraph: require './dot-graph-pdf.coffee'

processParameters = (referenceFileName, fileToGraph, operation, types, subtypes, outputFileName) ->

  defaultOperation = 'graph'
  defaultType = _.first (v for key, v of Constants.SupportedTypes)
  defaultSubType = null

  operation = defaultOperation unless operation?
  types = defaultType unless types?
  subtypes = null unless subtypes?

  unless referenceFileName? and fileToGraph? and operation in Object.keys availableOperations
    console.log "Usage: swift-relationship-graph
      #{'<pathToReferenceJSON>'.magenta}
      #{'<pathToJSONToGraph>'.magenta}
      #{'[<operation>, <type or root node...>, <subtypes>, <pathToOutputFile>]'.yellow}"
    console.log ''

    ops = _.map availableOperations, (value, key) ->
      if key is defaultOperation
        return "#{key}".underline.green
      return "#{key}".blue
    ops = ops.join ', '

    supportedTypes = _.map Constants.SupportedTypes, (value) ->
      if value is defaultType
        return "#{value}".underline.green
      return "#{value}".blue
    supportedTypes = supportedTypes.join ', '
    
    supportedSubTypes = _.map Constants.SupportedSubTypes, (value) ->
      if value is defaultType
        return "#{value}".underline.green
      return "#{value}".blue
    supportedSubTypes = supportedSubTypes.join ', '

    console.log "Available #{'<operation>'.yellow}s: #{ops}"
    console.log "Available #{'<type...>'.yellow}s (multiple values allowed,
                 comma separated): #{supportedTypes}"
    console.log "Available #{'<subtype...>'.yellow}s (multiple values allowed,
                 comma separated;  defaults to #{'no'.underline.green} subtypes): #{supportedSubTypes}"

    console.log ''

    return null

  return {
    referenceFileName: referenceFileName
    fileToGraph: fileToGraph
    operation: operation
    types: types
    subtypes: subtypes
    outputFileName: outputFileName
  }

run = (parameters) ->

  operation = parameters.operation
  types = parameters.types
  subtypes = parameters.subtypes
  outputFileName = parameters.outputFileName
  referenceFileName = parameters.referenceFileName
  fileToGraph = parameters.fileToGraph

  referenceFileName = path.resolve './', referenceFileName unless path.isAbsolute referenceFileName
  fileToGraph = path.resolve './', fileToGraph unless path.isAbsolute fileToGraph

  fs.readFileAsync( referenceFileName )
    .then (refernceData) ->
      return JSON.parse refernceData.toString()
    .then (referenceJson) ->
        fs.readFileAsync( fileToGraph )
        .then (dataToGraph) ->
            return JSON.parse dataToGraph.toString()
        .then (jsonToGraph) ->
            availableOperations[operation] referenceJson, jsonToGraph, types, subtypes, outputFileName
    .caught (error) ->

      console.error ''

      switch error.errno
        when -os.constants.errno.ENOENT
          console.error "#{"ERROR:".red} Couldn't open file #{referenceFileName.magenta}"
        else
          console.error error

      console.error ''

      process.exit 1

module.exports =
  processParameters: processParameters
  run: run
