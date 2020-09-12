module.exports = {
  chainWebpack: config => {
    config
      .plugin('html')
      .tap(
        args => {
          args[0].title = 'CloudControl'
          return args
        }
      )
  },
  publicPath: '/client/',
  "transpileDependencies": [
    "vuetify"
  ]
}
