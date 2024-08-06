<template>
  <v-card max-width="100em">
    <template v-slot:loader>
      <v-progress-linear
          color="primary"
          height="4"
          indeterminate
      ></v-progress-linear>
    </template>
    <v-card-title class="pa-8">
      <v-banner :avatar="logoUrl">
        <v-banner-text>CloudControl Center</v-banner-text>
      </v-banner>
    </v-card-title>
    <v-card-subtitle>CloudControl is starting up. Please wait.</v-card-subtitle>
    <v-card-text>
      <v-alert v-if="oAuthCode !== '' && oAuthUrl !== ''" type="info">
        CloudControlCenter has detected an authentication request. Click here to copy the authentication code
        into the clipboard and open the authentication URL:
        <v-btn v-on:click="doOAuth">
          Open Authentication
        </v-btn>
      </v-alert>
      <v-alert v-if="googleAuth && !completedAuth" type="info">
        CloudControlCenter has detected a Google authentication request. After you've clicked the following
        button and authenticated in, copy the Google authorization code you'll get into the text input below.
        <v-btn type="elevated" v-on:click="doOAuth">
          Open Authentication
        </v-btn>
        <v-form v-on:submit="sendGoogleAuth">
          <v-text-field autofocus v-model="googleAuthCode"></v-text-field>
          <v-btn type="submit">Send code</v-btn>
        </v-form>
      </v-alert>
      <v-alert v-if="requiresMFA" type="info">
        CloudControlCenter has detected an MFA code request. Enter the current code of your authenticator:
        <v-form v-on:submit="sendMfa">
          <v-text-field autofocus v-model="mfaCode"></v-text-field>
          <v-btn type="submit">Send code</v-btn>
        </v-form>
      </v-alert>
      <v-alert v-if="currentError !== ''" type="error">
        {{ currentError }}
      </v-alert>
      <v-card>
        <v-card-title>Installing {{ stepTitle }}</v-card-title>
        <v-card-text>
          <vue-markdown :source="stepDescription"></vue-markdown>
        </v-card-text>
      </v-card>
      <v-card id="console" theme="dark" outlined rounded="0" height="30em" max-height="30em"
              style="font-family: monospace; overflow: scroll">
        <v-card-text v-html="consoleOutput"></v-card-text>
      </v-card>
      <v-progress-linear color="primary" :model-value="(currentStep - 1) / steps.length * 100"/>
      <v-timeline direction="horizontal" side="end">
        <v-timeline-item size="small" v-for="(stepName, step) in steps" :ref="`${step + 1}-step`"
                         :icon="currentStep - 1 > step ? 'mdi-check' : ''" fill-dot dot-color="primary">{{ getStepTitle(stepName) }}
        </v-timeline-item>
      </v-timeline>
    </v-card-text>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, Ref } from 'vue';
import * as axios from 'axios';
import VueMarkdown from 'vue-markdown-render';
import logoUrl from '../assets/logo.svg?url';

let completedAuth: boolean = false;
let mfaCode: string = '';
let googleAuthCode: string = '';
let googleAuth: boolean = false;
let requiresMFA: boolean = false;
let currentError: string = '';
let stepDescription: string = 'Installing and configuring flavour';
let stepTitle: string = 'Flavour';
let oAuthUrl: string = '';
let oAuthCode: string = '';
let getStepInterval: NodeJS.Timer | null = null;
let consoleOutput: string = '';
let currentStep: number = 1;
let steps: string[] = [];
let features: any = [];

export default defineComponent({
  components: {
    VueMarkdown,
  },
  data() {
    return {
      steps,
      features,
      currentStep,
      consoleOutput,
      getStepInterval,
      oAuthCode,
      oAuthUrl,
      stepTitle,
      stepDescription,
      currentError,
      requiresMFA,
      googleAuth,
      googleAuthCode,
      mfaCode,
      completedAuth,
      logoUrl,
    };
  },
  async mounted() {
    this.steps = (await axios.default.get('/api/steps')).data.steps
    this.features = (await axios.default.get('/api/features')).data

    this.getStepInterval = setInterval(this.getCurrentStep.bind(this), 3000) as NodeJS.Timer;
  },
  methods: {
    getStepTitle(stepName: string) {
      if (stepName == 'flavour') {
        return 'Flavour'
      }
      return this.features[stepName].Title
    },
    async doOAuth() {
      if (this.oAuthCode !== '') {
        await navigator.clipboard.writeText(this.oAuthCode);
      }
      window.open(this.oAuthUrl);
    },
    getCurrentStep() {
      axios.default.get('/api/steps/current')
          .then(
              (backendStep) => {
                this.stepTitle = backendStep.data.title;
                this.stepDescription = backendStep.data.description;
                this.currentStep = backendStep.data.currentStep;
                this.consoleOutput = this.reformatOutput(backendStep.data.output);
                const consoleCard = document.getElementById('console');
                if (consoleCard) {
                  consoleCard.scrollTop = consoleCard.scrollHeight;
                }
              },
          )
          .catch((error) => {
            this.currentError = `Could not reach the ccc backend or the backend has reached an error state. Please
        use docker logs to show the log messages from the CloudControl container for details. The container might
        already been stopped, so you should use docker ps -a to look for it. `;
            if (error.response) {
              this.currentError = this.currentError + `([${error.response.status}] ${error.response.data})`;
            } else if (error.message) {
              this.currentError = this.currentError + `(${error.message})`;
            }
          });
    },
    reformatOutput(output: string) {
      // Replace newlines with br
      output = output.replaceAll('\n', '<br/>');

      this.oAuthCode = '';
      this.oAuthUrl = '';

      // Oauth feature
      const azureOauthRegexp = new RegExp(
          'https://microsoft.com/devicelogin and enter the code ([^ ]+) to authenticate.',
      );
      if (azureOauthRegexp.test(output)) {
        const matches = azureOauthRegexp.exec(output);
        if (matches) {
          this.oAuthUrl = 'https://microsoft.com/devicelogin';
          this.oAuthCode = matches[ 1 ];
        }
      }

      const googleOauthRegexp = new RegExp('Go to the following link in your browser, and complete the sign-in prompts:\r<br/>\r<br/> +(.+)');
      if (googleOauthRegexp.test(output)) {
        const matches = googleOauthRegexp.exec(output);
        if (matches) {
          this.oAuthUrl = matches[ 1 ];
          this.googleAuth = true;
        }
      }
      // MFA feature. Check for a regexp request, but also check if the MFA was already entered.
      const mfaRegexp = new RegExp('/tmp/mfa');
      const mfaDoneRegExp = new RegExp('\\[VALID_CODE]');

      this.requiresMFA = mfaRegexp.test(output) && !mfaDoneRegExp.test(output);

      return output;
    },
    beforeDestroy() {
      clearInterval(this.getStepInterval as NodeJS.Timer);
      this.getStepInterval = null;
    },
    sendMfa(event: Event) {
      event.preventDefault();
      axios.default.post('/api/mfa', {
        code: this.mfaCode,
      })
          .then(() => {
            this.requiresMFA = false;
            this.currentError = '';
          })
          .catch((error) => {
            this.currentError = 'Can not set MFA code:';
            if (error.response) {
              this.currentError = `${this.currentError} ([${error.response.status}] ${error.response.data})`;
            } else if (error.message) {
              this.currentError = `${this.currentError} (${error.message})`;
            }
          });
    },
    sendGoogleAuth(event: Event) {
      event.preventDefault();
      axios.default.post('/api/googleAuth', {
        code: this.googleAuthCode,
      })
          .then(() => {
            this.googleAuth = false;
            this.googleAuthCode = '';
            this.currentError = '';
            this.completedAuth = true;
          })
          .catch((error) => {
            this.currentError = 'Can not set Google Auth code:';
            if (error.response) {
              this.currentError = `${this.currentError} ([${error.response.status}] ${error.response.data})`;
            } else if (error.message) {
              this.currentError = `${this.currentError} (${error.message})`;
            }
          });
    },
  },
});

</script>

<style>
/* Required because of https://github.com/vuetifyjs/vuetify/issues/18176 */
.v-timeline--horizontal.v-timeline .v-timeline-item__body {
  padding-inline-end: 0 !important;
}
</style>
