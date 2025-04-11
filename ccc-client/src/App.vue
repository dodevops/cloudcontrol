<template>
  <v-app>
    <v-layout ref="app">
      <v-main class="d-flex align-center justify-center">
        <v-container>
          <Progress v-if="status === 'INIT'"/>
          <MainScreen v-if="status === 'INITIALIZED'"/>
        </v-container>
      </v-main>
      <v-footer app>
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
    </v-layout>
  </v-app>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, Ref, ref } from 'vue';
import * as axios from 'axios';
import MainScreen from '@/components/MainScreen.vue';
import logoUrlImport from './assets/logo.svg?url';
import Progress from '@/components/Progress.vue';

const status = ref('');
const loadStatusInterval: Ref<NodeJS.Timer | null> = ref(null);
const logoUrl = ref(logoUrlImport);

async function loadStatus() {
  const backendStatus = await axios.default.get('/api/status');
  status.value = backendStatus.data.status;
}

onMounted(async () => {
  loadStatusInterval.value = setInterval(loadStatus.bind(this), 3000);
  await loadStatus();
});

onUnmounted(() => {
  if (loadStatusInterval.value) {
    clearInterval(loadStatusInterval.value as NodeJS.Timer);
  }
  loadStatusInterval.value = null;
});
</script>
