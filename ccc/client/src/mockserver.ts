import { Server, Model } from 'miragejs';
import { LoremIpsum } from 'lorem-ipsum';

export function makeMockServer({ environment = 'development' } = {}) {
  return new Server({
    environment,
    routes() {
      let status = 'INIT';
      const steps = [
        'flavour',
        'kubernetes',
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
        if (status === 'INIT') {
          currentStep++;
          if (currentStep >= steps.length) {
            status = 'INITIALIZED';
          }
        }

        return {
          currentStep,
          output: new LoremIpsum().generateSentences(Math.floor(Math.random() * 20 + 20)),
          title: 'Feature',
          description: 'Some [Test](https://google.com)',
        };
      });
      this.get('/features', () => {
        return {
          kubernetes: {
            Title: 'Kubernetes',
            Description: 'Installs and configures [kubernetes](https://kubernetes.io/docs/reference/kubectl/overview/) with [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) to connect to the flavour&#x27;s kubernetes clusters',
          },
          terraform: {
            Title: 'Terraform',
            Description: 'Installs and configures [Terraform](https://terraform.io)',
          },
          kc: {
            Title: 'kc',
            Description: 'Installs [kc](https://github.com/dodevops/cloudcontrol/blob/master/feature/kc/kc.sh), a quick context switcher for kubernetes.',
          },
        };
      });
    },
  });
}
