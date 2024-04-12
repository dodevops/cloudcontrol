<template>
  <v-app>
    <v-main>
      <v-container class="fill-height" fluid>
        <v-row align="center" justify="center">
          <v-col cols="12" sm="8" md="8">
            <Startup v-if="status === 'INIT'"/>
            <MainScreen v-if="status === 'INITIALIZED'"/>
          </v-col>
        </v-row>
      </v-container>
      <v-footer absolute>
        <v-sheet class="text-body-2 w-100">
          <v-container fluid>
            <v-row dense>
              <v-col>
                <v-img height="2em" :src="logoUrl"></v-img>
              </v-col>
              <v-col class="text-left">
                <a href="https://cloudcontrol.dodevops.io">CloudControl</a> - The cloud engineer's toolbox.
              </v-col>
            </v-row>
          </v-container>
        </v-sheet>
      </v-footer>
    </v-main>
  </v-app>
</template>

<script lang="ts">
import Vue, { defineComponent } from 'vue';
import Progress from '@/components/Progress.vue';
import * as axios from 'axios';
import MainScreen from '@/components/MainScreen.vue';
import logoUrl from './assets/logo.svg?url';

let status: string = 'INIT';
let loadStatusInterval: NodeJS.Timer | null = null;

export default defineComponent({
  components: { MainScreen, Startup: Progress },
  data() {
    return {
      status,
      loadStatusInterval,
      logoUrl,
    };
  },
  created() {
    this.loadStatusInterval = setInterval(this.loadStatus.bind(this), 3000);
    this.loadStatus();
  },
  methods: {
    beforeDestroy() {
      if (this.loadStatusInterval) {
        clearInterval(loadStatusInterval as NodeJS.Timer);
      }
      this.loadStatusInterval = null;
    },
    loadStatus() {
      axios.default.get('/api/status')
        .then(
          (backendStatus) => {
            this.status = backendStatus.data.status;
          },
        );
    },
  },
});

</script>
