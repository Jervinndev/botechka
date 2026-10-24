<script setup>
import Header from './components/admin/header.vue';
import Footer from './components/admin/Footer.vue';
import Overlay from './components/layout/overlay.vue';
import Progressbarloader from './Skelitonloader/Progressbarloader.vue';
import { computed, onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute()
const router = useRouter()
const startupLoaderKey = 'botechka-startup-loader-shown'
const Isloading = ref(localStorage.getItem(startupLoaderKey) !== 'true')
const isRouterReady = ref(false)

const showcomponents = computed(() => !route.meta.hideHeader);

function finishLoading() {
  localStorage.setItem(startupLoaderKey, 'true')
  Isloading.value = false
}

onMounted(async () => {
  await router.isReady()
  isRouterReady.value = true
})
</script>

<template>
  <div>
    <div v-if="!isRouterReady" class="fixed inset-0 z-100 bg-gray-100"></div>
    <div v-else-if="Isloading" class="fixed inset-0 z-100">
      <Progressbarloader @complete="finishLoading" />
    </div>
    <template v-else-if="isRouterReady">
      <Header v-if="showcomponents" />
      <div class="bg-gray-100">
        <!-- <Overlay /> -->
        <router-view />
      </div>
      <Footer v-if="showcomponents" />
    </template>
  </div>
</template>
