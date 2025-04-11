<template>
  <v-card>
    <v-card-title class="pa-8">
      <v-banner :avatar="logoUrl">
        <v-banner-text>CloudControl Center</v-banner-text>
      </v-banner>
    </v-card-title>
    <v-card-text>
      <v-row>
        <v-col>
          <p>CloudControl has been initialized. Run the following to enter the container:</p>
          <v-banner theme="dark" lines="one" class="my-4">
            <v-banner-text>
              docker-compose exec cli /usr/local/bin/cloudcontrol run
            </v-banner-text>
            <template v-slot:actions>
              <v-btn icon="mdi-content-copy"
                     v-on:click="copyCommand('docker-compose exec cli /usr/local/bin/cloudcontrol run')">
              </v-btn>
            </template>
          </v-banner>
          <p>If you want to change a configuration in your docker-compose.yaml,
            <strong>rerun the init script</strong> to apply the changes.</p>
        </v-col>
      </v-row>
      <v-row>
        <v-col>
          <v-list>
            <v-list-subheader>Installed features</v-list-subheader>
            <v-list-item v-for="(feature, step) in features">
              <template v-slot:prepend>
                <v-avatar>{{ feature.Icon }}</v-avatar>
              </template>
              <v-list-item-title>
                {{ feature.Title }}
              </v-list-item-title>
              <v-list-item-subtitle>
                <vue-markdown :source="feature.Description"></vue-markdown>
              </v-list-item-subtitle>
            </v-list-item>
          </v-list>
        </v-col>
      </v-row>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { onMounted, Ref, ref } from 'vue';
import * as axios from 'axios';
import VueMarkdown from 'vue-markdown-render';
import logoUrlImport from '../assets/logo.svg?url';

interface Feature {
  Icon: string;
  Title: string;
  Description: string;
}

const features: Ref<Feature[]> = ref([])
const logoUrl = ref(logoUrlImport)

async function copyCommand(command: string) {
  await navigator.clipboard.writeText(command)
}

onMounted(async () => {
  const backendFeatures = await axios.default.get('/api/features')
  features.value = backendFeatures.data
})
</script>

<style scoped>

</style>
