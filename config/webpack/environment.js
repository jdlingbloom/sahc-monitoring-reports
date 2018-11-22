const { environment } = require('@rails/webpacker')

environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader',
  options: {
    attempts: 1
  }
});

environment.config.merge({
  resolve: {
    alias: {
      'jquery.dirtyforms': 'jquery.dirtyforms/jquery.dirtyforms',
    },
  },
  externals: {
    // Treat window and document as an external to fix jquery.dirtyforms
    // import:
    // https://github.com/snikch/jquery.dirtyforms/issues/82#issuecomment-376834484
    window: 'window',
    document: 'document',
  },
});

module.exports = environment
