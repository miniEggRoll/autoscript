module.exports = 
    csvSetting: 
        headers: true
        discardUnmappedColumns: true
        ignoreEmpty: false
        delimiter: ','
        quote: '"'
        trim: true
    defaultArgs:
        spec1: ''
        spec3: ''
        spec5: ''
        spec6: ''
        promotion_title: ''
        promotion: ''
    mysqlConfig: 
        host: process.env.LC_SABRINA_HOST
        port: process.env.LC_SABRINA_PORT
        user: process.env.LC_SABRINA_USER
        password: process.env.LC_SABRINA_PASSWORD
