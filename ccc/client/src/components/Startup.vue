<template>
  <v-card>
    <v-card-title>☁️ 🧰 Starting CloudControl</v-card-title>
    <v-card-text>
      <p>CloudControl is starting up. Please wait.</p>
      <v-card id="console" dark outlined rounded="0" height="30em" max-height="30em" style="font-family: monospace; overflow-y: scroll">
        <v-card-text>{{ consoleOutput }}</v-card-text>
      </v-card>
      <v-stepper>
        <v-stepper-header>
          <v-stepper-step v-for="(stepName, step) in steps" :complete="currentStep > step" :step="step + 1">{{stepName}}</v-stepper-step>
        </v-stepper-header>
      </v-stepper>
    </v-card-text>
    <v-card-actions>
      <v-progress-linear :value="currentStep / steps.length * 100"/>
    </v-card-actions>
  </v-card>
</template>

<script lang=ts>
import Component from "vue-class-component";
import Vue from "vue";
import * as axios from 'axios';

@Component({})
export default class Startup extends Vue {
  public steps: string[] = []
  public currentStep: number = 1
  public consoleOutput: string = ""

  public getStepInterval: number = -1

  mounted() {
    axios.default.get('/api/steps')
    .then(
        backendSteps => {
          this.steps = backendSteps.data;
        }
    )
    this.getStepInterval = setInterval(this.getCurrentStep.bind(this), 3000)
  }

  getCurrentStep() {
    axios.default.get('/api/steps/current')
    .then(
        backendStep => {
          this.currentStep = backendStep.data.currentStep
          this.consoleOutput = backendStep.data.output
          const consoleCard = document.getElementById('console')
          if (consoleCard) {
            consoleCard.scrollTop = consoleCard.scrollHeight;
          }
        }
    )
  }

  beforeDestroy() {
    clearInterval(this.getStepInterval)
    this.getStepInterval = -1
  }
}
</script>

<style scoped>

</style>
