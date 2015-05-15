path    = require 'path'
co      = require 'co'

{
    checkLocalesInDB
    sortByInsertAndUpdate
    mapper
} = require "#{__dirname}/util"


filename = path.join __dirname, 'csv/th.csv'

co ->
    mapping = mapper 'th_TH', filename

    yield [mapping, checkLocalesInDB]
.then sortByInsertAndUpdate ['en_US', 'th_TH']
.catch (err)->
    console.error err.stack
