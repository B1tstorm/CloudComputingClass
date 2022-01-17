import log4js from "log4js";

log4js.configure({
    appenders: {
        // everything: { type: 'file', filename: 'all-the-logs.log' }, //produces logfile, add to categories appenders
        out: {
            type: 'stdout',
            layout: {
                type: 'pattern', pattern: '%d %[%p%] %c %f{1}:%l %m'
            }
        }
    },
    categories: {
        default: { appenders: ['out'], level: 'info', enableCallStack: true }
    }
});

export const log = log4js.getLogger()

log.level = "info"; // debug > info; sets logging level