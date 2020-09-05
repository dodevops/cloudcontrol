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
                md="4"
            >
              <Startup v-if="status === 'INIT'"/>
              <MainScreen v-if="status === 'INITIALIZED'"/>
            </v-col>
          </v-row>
        </v-container>
    </v-main>
  </v-app>
</template>

<script lang="ts">
import Vue from "vue";
import Startup from "@/components/Startup.vue";
import { Component } from "vue-property-decorator";
import * as axios from 'axios'
import MainScreen from "@/components/MainScreen.vue";

@Component({
  components: { MainScreen, Startup }
})
export default class App extends Vue {
  status: string = ""

  loadStatusInterval: number = -1

  created() {
    this.loadStatusInterval = setInterval(this.loadStatus.bind(this), 3000)
    this.loadStatus()
  }

  beforeDestroy() {
    clearInterval(this.loadStatusInterval)
    this.loadStatusInterval = -1
  }

  loadStatus() {
    axios.default.get('/api/status')
    .then(
        backendStatus => {
          this.status = backendStatus.data.status
        }
    )
  }
}
</script>
