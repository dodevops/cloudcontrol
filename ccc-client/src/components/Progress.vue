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

<script setup lang="ts">
import { onBeforeUnmount, onMounted, Ref, ref, toRaw } from 'vue';
import * as axios from 'axios';
import logoUrlImport from '../assets/logo.svg?url';

interface Feature {
  Title: string
}

const steps: Ref<string[]> = ref([])
const features: Ref<{[key: string]: Feature}> = ref({})
const getStepInterval: Ref<NodeJS.Timer | null> = ref(null)
const stepTitle = ref('')
const stepDescription = ref('')
const currentStep = ref(1)
const consoleOutput = ref('')
const currentError = ref('')

const oAuthCode = ref('')
const oAuthUrl = ref('')
const googleAuth = ref(false)
const requiresMFA = ref(false)
const mfaCode = ref('')
const googleAuthCode = ref('')
const completedAuth = ref(false)

const logoUrl = ref(logoUrlImport)

function reformatOutput(output: string) {
  // Replace newlines with br
  output = output.replaceAll('\n', '<br/>');

  oAuthCode.value = '';
  oAuthUrl.value = '';

  // Oauth feature
  const azureOauthRegexp = new RegExp(
    'https://microsoft.com/devicelogin and enter the code ([^ ]+) to authenticate.',
  );
  if (azureOauthRegexp.test(output)) {
    const matches = azureOauthRegexp.exec(output);
    if (matches) {
      oAuthUrl.value = 'https://microsoft.com/devicelogin';
      oAuthCode.value = matches[ 1 ];
    }
  }

  const googleOauthRegexp = new RegExp('Go to the following link in your browser, and complete the sign-in prompts:\r<br/>\r<br/> +(.+)');
  if (googleOauthRegexp.test(output)) {
    const matches = googleOauthRegexp.exec(output);
    if (matches) {
      oAuthUrl.value = matches[ 1 ];
      googleAuth.value = true;
    }
  }
  // MFA feature. Check for a regexp request, but also check if the MFA was already entered.
  const mfaRegexp = new RegExp('/tmp/mfa');
  const mfaDoneRegExp = new RegExp('\\[VALID_CODE]');

  requiresMFA.value = mfaRegexp.test(output) && !mfaDoneRegExp.test(output);

  return output;
}

async function getCurrentStep() {
  try {
    const backendStep = await axios.default.get('/api/steps/current')
    stepTitle.value = backendStep.data.title;
    stepDescription.value = backendStep.data.description;
    currentStep.value = backendStep.data.currentStep;
    consoleOutput.value = reformatOutput(backendStep.data.output);
    const consoleCard = document.getElementById('console');
    if (consoleCard) {
      consoleCard.scrollTop = consoleCard.scrollHeight;
    }
  } catch (error: any) {
    currentError.value = `Could not reach the ccc backend or the backend has reached an error state. Please
        use docker logs to show the log messages from the CloudControl container for details. The container might
        already been stopped, so you should use docker ps -a to look for it. `;
    if (error.response) {
      currentError.value += `([${error.response.status}] ${error.response.data})`;
    } else if (error.message) {
      currentError.value += `(${error.message})`;
    }
  }
}

function getStepTitle(stepName: string) {
  if (stepName == 'flavour') {
    return 'Flavour'
  }
  if (stepName in features.value) {
    return features.value[stepName].Title
  }
  return ''
}

async function doOAuth() {
  if (oAuthCode.value !== '') {
    await navigator.clipboard.writeText(oAuthCode.value);
  }
  window.open(oAuthUrl.value);
}

async function sendMfa(event: Event) {
  event.preventDefault();
  try {
    await axios.default.post('/api/mfa', {
      code: mfaCode.value,
    })
    requiresMFA.value = false
    currentError.value = ''
  } catch (error: any) {
    currentError.value = 'Can not set MFA code:';
    if (error.response) {
      currentError.value = `${currentError.value} ([${error.response.status}] ${error.response.data})`;
    } else if (error.message) {
      currentError.value = `${currentError.value} (${error.message})`;
    }
  }
}

async function sendGoogleAuth(event: Event) {
  event.preventDefault();
  try {
    await axios.default.post('/api/googleAuth', {
      code: googleAuthCode.value,
    })
    googleAuth.value = false
    googleAuthCode.value = ''
    currentError.value = ''
    completedAuth.value = true
  } catch (error: any) {
    currentError.value = 'Can not set Google Auth code:';
    if (error.response) {
      currentError.value = `${currentError.value} ([${error.response.status}] ${error.response.data})`;
    } else if (error.message) {
      currentError.value = `${currentError.value} (${error.message})`;
    }
  }
}

onMounted(async () => {
  try {
    const stepsRequest = await axios.default.get('/api/steps')
    steps.value = stepsRequest.data.steps
    const featuresRequest = await axios.default.get('/api/features')
    features.value = featuresRequest.data
    getStepInterval.value = setInterval(getCurrentStep.bind(this), 3000) as NodeJS.Timer;
  } catch (error: any) {
    currentError.value = 'Can not communicate with backend:';
    if (error.response) {
      currentError.value = `${currentError.value} ([${error.response.status}] ${error.response.data})`;
    } else if (error.message) {
      currentError.value = `${currentError.value} (${error.message})`;
    }
  }
})

onBeforeUnmount(() => {
  clearInterval(getStepInterval.value as NodeJS.Timer);
  getStepInterval.value = null;
})
</script>

<style>
/* Required because of https://github.com/vuetifyjs/vuetify/issues/18176 */
.v-timeline--horizontal.v-timeline .v-timeline-item__body {
  padding-inline-end: 0 !important;
}
</style>
