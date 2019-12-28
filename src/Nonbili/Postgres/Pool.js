const Pool = require("pg").Pool;

exports.newPool_ = poolConfig => connConfig => () =>
  new Pool(Object.assign({}, poolConfig, connConfig));

exports.connect_ = pool => () => pool.connect();

exports.end_ = pool => () => pool.end();

exports.release_ = client => () => client.release();

exports.query_ = client => qs => params =>
  async function() {
    const res = await client.query(qs, params);
    return {
      rows: res.rows,
      rowCount: res.rowCount
    };
  };
