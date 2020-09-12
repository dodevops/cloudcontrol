<template>
  <v-app>
    <v-main>
      <v-container
          class="fill-height"
          fluid
      >
        <v-row
            align="center"
            justify="center"
        >
          <v-col
              cols="12"
              sm="8"
              md="8"
          >
            <Startup v-if="status === 'INIT'"/>
            <MainScreen v-if="status === 'INITIALIZED'"/>
          </v-col>
        </v-row>
      </v-container>
      <v-footer absolute>
        <v-col
            class="text-center"
            cols="12"
        >
          ☁️ 🧰 <a href="https://cloudcontrol.dodevops.io">CloudControl</a> - The cloud engineer's toolbox.
        </v-col>
      </v-footer>
    </v-main>
  </v-app>
</template>

<script lang="ts">
import Vue from 'vue';
import Progress from '@/components/Progress.vue';
import { Component } from 'vue-property-decorator';
import * as axios from 'axios';
import MainScreen from '@/components/MainScreen.vue';

@Component({
  components: { MainScreen, Startup: Progress },
})
export default class App extends Vue {
  public status: string = 'INIT';

  public loadStatusInterval: number = -1;

  public created() {
    this.loadStatusInterval = setInterval(this.loadStatus.bind(this), 3000);
    this.loadStatus();
  }

  public beforeDestroy() {
    clearInterval(this.loadStatusInterval);
    this.loadStatusInterval = -1;
  }

  public loadStatus() {
    axios.default.get('/api/status')
        .then(
            (backendStatus) => {
              this.status = backendStatus.data.status;
            },
        );
  }
}
</script>
