<template>
  <v-card>
    <v-card-title>☁️ 🧰 CloudControl Center</v-card-title>
    <v-card-text>
      <v-row>
        <v-col cols="12">
          <p>CloudControl has been initialized. Run the following to enter the container:</p>
          <v-card dark outlined rounded="0" style="font-family: monospace">
            <v-card-text>
              <v-row dense align=center>
                <v-col cols="11">
                  docker-compose exec cli /usr/local/bin/cloudcontrol run
                </v-col>
                <v-col cols="1" style="text-align: right">
                  <v-btn v-on:click="copyCommand('docker-compose exec cli /usr/local/bin/cloudcontrol run')">
                    <v-icon>mdi-content-copy</v-icon>
                  </v-btn>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12">
          If you want to change a configuration in your docker-compose.yaml,
          <strong>rerun the init script</strong> to apply the changes.
        </v-col>
      </v-row>
      <v-row>
        <v-col cols=12>
          <v-list>
            <v-subheader>Installed features</v-subheader>
            <v-list-item v-for="(feature, step) in features">
              <v-list-item-icon>{{ feature.Icon }}</v-list-item-icon>
              <v-list-item-title>{{ feature.Title }}</v-list-item-title>
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

<script lang=ts>
import { Component } from 'vue-property-decorator';
import Vue from 'vue';
import * as axios from 'axios';
import VueMarkdown from 'vue-markdown-render';

interface Feature {
  Icon: string;
  Title: string;
  Description: string;
}

@Component({
  components: {
    VueMarkdown,
  },
})
export default class extends Vue {
  public features: Feature[] = [];

  public mounted() {
    axios.default.get('/api/features')
        .then(
            (backendFeatures) => {
              this.features = backendFeatures.data;
            },
        );
  }

  public async copyCommand(command: string) {
    await navigator.clipboard.writeText(command);
  }
}
</script>

<style scoped>

</style>
