/**
 * main.ts
 *
 * Bootstraps Vuetify and other plugins then mounts the App`
 */

// Plugins
import { registerPlugins } from '@/plugins'

// Components
import App from './App.vue'
import { makeMockServer } from './mockserver'

// Composables
import { createApp } from 'vue'

if (process.env.NODE_ENV === 'development') {
  makeMockServer();
}

const app = createApp(App)

registerPlugins(app)

app.mount('#app')
