module.exports = {
  test: /\.(jpg|jpeg|png|gif|tiff|ico|svg)$/i,
  use: [{
    loader: 'url-loader',
    options: {
      limit: 10000,
      name: '[path][name]-[hash].[ext]',
    },
  }]
};
