import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import myIntegration from './my-toolbar-app/my-integration.ts';

// https://astro.build/config
export default defineConfig({
  integrations: [
    myIntegration,
    starlight({
      title: 'Vonage Onboarding',
      tableOfContents: false,
      pagefind: false,
    }),
  ],
});
