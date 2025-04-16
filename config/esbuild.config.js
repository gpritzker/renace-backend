// config/esbuild.config.js
module.exports = {
    loader: {
      '.js': 'jsx'
    },
    external: [
      '@hotwired/turbo-rails',
      'bootstrap',
      'bootstrap/dist/js/bootstrap'
    ]
  }