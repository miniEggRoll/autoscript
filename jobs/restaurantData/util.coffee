co      = require 'co'
fs      = require 'fs'
csv     = require 'fast-csv'
_       = require 'underscore'
mysql   = require 'mysql'
RSVP    = require 'rsvp'
config  = require "#{__dirname}/config"

{csvSetting,mysqlConfig,defaultArgs} = config
pool = mysql.createPool mysqlConfig

makeCase = (col, arr, fields)->
    "`#{col}` = CASE\n" +
    arr.map (ele)->
        val = ele[col]
        c = fields.map (field)->
            mysql.format "?? = ?", [field, ele[field]]
        .join ' AND '
        mysql.format "WHEN #{c} THEN ?\n", [val]
    .join('') + 
    "ELSE `#{col}` END\n"

module.exports = 
    mapper: (locale, filename)->
        new RSVP.Promise (resolve, reject)->
            restaurants = []
            csv.fromPath filename, csvSetting
            .validate (data)->
                _.isFinite data.id
            .transform (data)->
                id = parseInt data.id, 10
                
                name = {en_US: data['Name[en_US]']}
                name[locale] = data["Name[#{locale}]"]

                intro1 = {en_US: data['Intro[en_US]']}
                intro1[locale] = data["Intro[#{locale}]"]

                highlight = {en_US: data['Highlight[en_US]']}
                highlight[locale] = data["Highlight[#{locale}]"]

                spec4 = {en_US: data['Transportation[en_US]']}
                spec4[locale] = data["Transportation[#{locale}]"]

                recommended_dishes = {en_US: _.compact data['Recommended Dishes[en_US]'].split /\s*,\s*/}
                recommended_dishes[locale] = _.compact data["Recommended Dishes[#{locale}]"].split /\s*,\s*/

                memo = {en_US: data['Open Hour Memo[en_US]']}
                memo[locale] = data["Open Hour Memo[#{locale}]"]

                {id, name, intro1, highlight, spec4, recommended_dishes, memo, live_music: data['Live Music'] is 'Yes', menu_url: data['Menu Url']}
            .on 'data', (data)->
                restaurants.push data
            .on 'end', ->
                resolve restaurants

    sortByInsertAndUpdate: (locales)->
        ([restaurants, localesInDB])->
            insert = []
            update = []
            live_music = []

            locales.forEach (locale)->
                restaurants.forEach (restaurant)->
                    has_live_music = if restaurant.live_music then 1 else 0
                    lc = _.findWhere localesInDB, {id: restaurant.id}
                    args = 
                        id: restaurant.id
                        locale: locale
                        name: restaurant.name[locale]
                        highlight: restaurant.highlight[locale]
                        recommended_dishes: restaurant.recommended_dishes[locale].join ', '
                        memo: restaurant.memo[locale]
                        intro1: restaurant.intro1[locale]
                        spec4: restaurant.spec4[locale]

                    unless (lc? and locale in lc.locale) then insert.push _.extend(args, defaultArgs) else update.push args
                    live_music.push {id: restaurant.id, live_music: has_live_music}

            if insert.length > 0 
                i = mysql.format("INSERT INTO `restaurant`.`lc_restaurant` (??)\nVALUES\n", [_.keys insert[0]]) + insert.map((args)->
                    mysql.format """(?)""", [_.values args]
                ).join(',\n') + ';'

            u = """
                UPDATE `restaurant`.`lc_restaurant` SET 
                #{makeCase('name', update, ['id', 'locale'])},
                #{makeCase('highlight', update, ['id', 'locale'])},
                #{makeCase('recommended_dishes', update, ['id', 'locale'])},
                #{makeCase('memo', update, ['id', 'locale'])},
                #{makeCase('intro1', update, ['id', 'locale'])},
                #{makeCase('spec4', update, ['id', 'locale'])};
                """

            l = "UPDATE `eztable`.`data1` SET\n" +
                makeCase('live_music', live_music, ['id']) + ';'

            co ->
                query = [u, l, i]
                .join '\n'
                .replace /↵+/g, '\n'

                yield (done)->
                    fs.writeFile "#{__dirname}/sql/#{locales.join('_')}.sql", query, done
            .then ->
                do pool.end

    checkLocalesInDB: (done)->
        pool.query """
        SELECT id, GROUP_CONCAT(DISTINCT locale ORDER BY locale DESC SEPARATOR ',') AS locale
        FROM `restaurant`.`lc_restaurant`
        GROUP BY id
        """, (err, results, fields)->
            results.forEach (r)->
                r.locale = r.locale.split ','
            done err, results
    checkHackRestaurants: (done)->
        pool.query """
        SELECT id FROM `eztable`.`data1`
        WHERE `is_hack` = 'Y'
        """, (err, results, fields)->
            done err, _.pluck(results, 'id')
