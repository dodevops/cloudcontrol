import { Server, Model, Response } from 'miragejs';
import { LoremIpsum } from 'lorem-ipsum';

export function makeMockServer({ environment = 'development' } = {}) {
  return new Server({
    environment,
    routes() {
      let status = 'INIT';
      let waitForMfa = false;
      const steps = [
        'flavour',
        'kubernetes',
        'terraform',
        'kc',
      ];
      let currentStep = 1;
      this.namespace = 'api';
      this.get('/status', () => {
        return {
          status,
        };
      });
      this.get('/steps', () => {
        return {
          steps,
        };
      });
      this.get('/steps/current', () => {
        let output = new LoremIpsum().generateSentences(Math.floor(Math.random() * 20 + 20));
        if (status === 'INIT') {
          if (currentStep === 1 && !waitForMfa) {
            output = '/tmp/mfa';
            waitForMfa = true;
          }
          if (!waitForMfa) {
            currentStep++;
          }
          if (currentStep >= steps.length) {
            status = 'INITIALIZED';
          }
        }

        return {
          currentStep,
          output,
          title: 'Feature',
          description: 'Some [Test](https://google.com)',
        };
      });
      this.get('/features', () => {
        return {
          kubernetes: {
            Icon: '🐳',
            Title: 'Kubernetes',
            Description: 'Installs and configures [kubernetes](https://kubernetes.io/docs/reference/kubectl/overview/) with [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) to connect to the flavour&#x27;s kubernetes clusters',
          },
          terraform: {
            Icon: '🌏',
            Title: 'Terraform',
            Description: 'Installs and configures [Terraform](https://terraform.io)',
          },
          kc: {
            Icon: '⌨️',
            Title: 'kc',
            Description: 'Installs [kc](https://github.com/dodevops/cloudcontrol/blob/master/feature/kc/kc.sh), a quick context switcher for kubernetes.',
          },
        };
      });
      this.post('/mfa', (schema, request) => {
        const code = JSON.parse(request.requestBody);
        if (code.code !== '1234') {
          return new Response(400, {}, 'Invalid code');
        } else {
          waitForMfa = false;
          currentStep++;
          return new Response(200, {}, {});
        }
      });
    },
  });
}
