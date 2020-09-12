import Vue from 'vue';
import App from './App.vue';
import vuetify from './plugins/vuetify';
import { makeMockServer } from './mockserver';

Vue.config.productionTip = false;

if (process.env.NODE_ENV === 'development') {
  makeMockServer();
}

new Vue({
  vuetify,
  render: (h) => h(App),
}).$mount('#app');
