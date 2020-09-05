<template>
  <v-card>
    <v-card-title>☁️ 🧰 CloudControl Center</v-card-title>
    <v-card-text>
      <p>CloudControl has been initialized. Execute the following to enter the container:</p>
      <v-card dark outlined rounded="0" style="font-family: monospace">
        <v-card-text>
          docker-compose exec app run
        </v-card-text>
      </v-card>
    </v-card-text>
    <v-card-actions>
      <v-btn>Restart CloudControl</v-btn>
      <v-btn>Reinitialize CloudControl</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script lang=ts>
import { Component } from "vue-property-decorator";
import Vue from 'vue'

@Component({})
export default class extends Vue {

}
</script>

<style scoped>

</style>
