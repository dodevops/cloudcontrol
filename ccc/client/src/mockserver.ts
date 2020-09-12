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
          feature1: {
            Title: 'test',
            Description: '*Test*',
          },
          feature2: {
            Title: 'test2',
            Description: 'Test2',
          },
        };
      });
    },
  });
}
