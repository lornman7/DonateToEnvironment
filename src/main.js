import { createApp } from 'vue'
import App from './App.vue'
import { providers, utils, bcs, encoding, version as starcoinVersion } from '@starcoin/starcoin'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'

createApp(App).use(ElementPlus).mount('#app')
