import { Server, Model } from 'miragejs';
import { LoremIpsum } from 'lorem-ipsum';

export function makeMockServer({ environment = 'development' } = {}) {
  return new Server({
    environment,
    routes() {
      this.namespace = 'api';
      this.get('/status', () => {
        return {
          status: ['INIT', 'INITIALIZED'][Math.floor(Math.random() * 2)],
        };
      });
      this.get('/steps', () => {
        return [
          'flavour',
          'kubernetes',
          'terraform',
        ];
      });
      this.get('/steps/current', () => {
        const step = Math.floor(Math.random() * 3 + 1);
        return {
          currentStep: step,
          output: new LoremIpsum().generateSentences(Math.floor(Math.random() * 20 + 20)),
        };
      });
    },
  });
}
