relationshipGraph = require '../lib/relationship-graph.coffee'

parameters = relationshipGraph.processParameters(
  process.argv[2],
  process.argv[3],
  process.argv[4],
  process.argv[5],
  process.argv[6],
  process.argv[7]
)

relationshipGraph.run parameters if parameters?
