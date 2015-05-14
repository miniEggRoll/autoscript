fs      = require 'fs'
_       = require 'underscore'
Form    = require 'form-data'
RSVP    = require 'rsvp'
co      = require 'co'
mysql   = require 'mysql'

imageDir = "#{__dirname}/images"

co ->
    yield (done)->
        fs.readdir imageDir, (err, files)->
            return done err if err?
            wrapped = files.map (id)-> 
                ->
                    co ->
                        form = new Form()
                        form.append 'image', fs.createReadStream "#{imageDir}/#{id}"

                        yield (_done)->
                            form.submit "http://pic-bed.eztable.com/upload/restaurant/#{id}", (err, response)->
                                return _done err if err?
                                str = ''
                                response.on 'data', (chunk)->
                                    str += chunk.toString()
                                .on 'end', ->
                                    if response.statusCode is 201  then _done null, JSON.parse(str) else _done new Error(str)
                    .then (info)-> co ->
                        return unless info?
                        links = 
                            o: _.findWhere(info, {format: 'width', size: 'raw'}).link
                            o128: _.findWhere(info, {format: 'width', size: 128}).link
                            o768: _.findWhere(info, {format: 'width', size: 768}).link
                            o1024: _.findWhere(info, {format: 'width', size: 1024}).link
                            s150: _.findWhere(info, {format: 'square', size: 150}).link

                        thumb0 = JSON.stringify [links]
                        thumb0_mini = links.s150

                        q = mysql.format """
                            UPDATE `eztable`.`data1`
                            SET ?
                            WHERE id = ?;\n
                            """, [{thumb0, thumb0_mini}, id]
                        {q, id}
                    .catch (err)->
                        console.log 'restaurant %s failed', id

            done null, wrapped
.then (wrapped)->
    query = ''
    worker = (idx)-> 
        co ->
            while wrapped.length
                job = wrapped.pop()
                {q, id} = yield job()
                query += q
                console.log 'restaurant %s finished', id
        .catch ->
            console.log "worker #{idx} down"

    RSVP.all(_.range(10).map worker).then ->
        query
.then (q)->
    fs.writeFile "#{__dirname}/query.sql", q, {encoding: 'utf8'}, (err)->
        if err? then console.error err
.catch (err)->
    console.error err.stack
