path    = require 'path'
co      = require 'co'

{
    checkLocalesInDB
    sortByInsertAndUpdate
    checkHackRestaurants
    mapper
} = require "#{__dirname}/util"

filename = path.join __dirname, 'csv/hk.csv'

co ->
    yield checkHackRestaurants
.then (hackIDs)-> co ->
    mapping = mapper 'zh_HK', filename
    .then (restautants)->
        restautants.map (r)->
            appendEN = if r.id in hackIDs then " (Contents and images are rightfully owned by #{r.name.en_US}, if there is any concern, please contact us.)" else ''
            appendHK = if r.id in hackIDs then " (相關文字與圖片為 #{r.name.zh_HK} 所有，若有侵權敬請告知)" else ''

            r.intro1.en_US += appendEN
            r.intro1.zh_HK += appendHK
            r

    yield [mapping, checkLocalesInDB]
.then sortByInsertAndUpdate ['en_US', 'zh_HK']
.catch (err)->
    console.error err.stack
