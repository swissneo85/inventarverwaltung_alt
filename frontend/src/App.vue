<template>
  <div class="app">
    <div v-if="!isAuthenticated" class="login-container">
      <router-view />
    </div>

    <template v-else>
      <div v-if="mobileDrawerOpen" class="mobile-backdrop" @click="mobileDrawerOpen = false"></div>

      <Sidebar
        :collapsed="sidebarCollapsed"
        :mobile-open="mobileDrawerOpen"
        @toggle="toggleSidebar"
        @close="mobileDrawerOpen = false"
      />

      <main class="main-content" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
        <header class="header">
          <div class="header-left">
            <button class="hamburger" @click="toggleSidebar" aria-label="Menü">
              <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="3" y1="12" x2="21" y2="12"></line>
                <line x1="3" y1="6" x2="21" y2="6"></line>
                <line x1="3" y1="18" x2="21" y2="18"></line>
              </svg>
            </button>
            <span class="page-title">{{ pageTitle }}</span>
          </div>
          <div class="header-right">
            <GlobalSearch />
            <UserMenu />
          </div>
        </header>

        <div class="content">
          <router-view />
        </div>
      </main>

      <!-- Bottom navigation – mobile only -->
      <nav class="bottom-nav" aria-label="Hauptnavigation">
        <router-link to="/" class="bnav-item" exact-active-class="router-link-active">
          <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect>
            <rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect>
          </svg>
          <span>Start</span>
        </router-link>
        <router-link to="/items" class="bnav-item">
          <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
          </svg>
          <span>Gegenstände</span>
        </router-link>
        <router-link to="/scan" class="bnav-item bnav-scan">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2v11z"></path>
            <circle cx="12" cy="13" r="4"></circle>
          </svg>
          <span>Scan</span>
        </router-link>
        <router-link to="/boxes" class="bnav-item">
          <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
            <line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line>
          </svg>
          <span>Boxen</span>
        </router-link>
        <router-link to="/inbox" class="bnav-item">
          <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="22 12 16 12 14 15 10 15 8 12 2 12"></polyline>
            <path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"></path>
          </svg>
          <span>Inbox</span>
        </router-link>
      </nav>
    </template>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import Sidebar from '@/components/Sidebar.vue'
import UserMenu from '@/components/UserMenu.vue'
import GlobalSearch from '@/components/GlobalSearch.vue'

const route = useRoute()
const authStore = useAuthStore()

const sidebarCollapsed = ref(false)
const mobileDrawerOpen = ref(false)
const windowWidth = ref(window.innerWidth)

const isMobile = computed(() => windowWidth.value < 1024)
const isAuthenticated = computed(() => authStore.isAuthenticated)
const pageTitle = computed(() => route.meta?.title || 'Inventarverwaltung')

function onResize() {
  windowWidth.value = window.innerWidth
  if (!isMobile.value) mobileDrawerOpen.value = false
}

onMounted(() => window.addEventListener('resize', onResize))
onUnmounted(() => window.removeEventListener('resize', onResize))

function toggleSidebar() {
  if (isMobile.value) {
    mobileDrawerOpen.value = !mobileDrawerOpen.value
  } else {
    sidebarCollapsed.value = !sidebarCollapsed.value
  }
}
</script>

<style lang="scss" scoped>
.app {
  display: flex;
  min-height: 100vh;
  background: #f8f9fa;
}

.login-container {
  min-height: 100vh;
  width: 100%;
}

.mobile-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 250;
}

/* ─── Desktop (≥ 1024px) ─── */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-left: 260px;
  transition: margin-left 0.3s ease;
  min-width: 0;
}

.main-content.sidebar-collapsed {
  margin-left: 70px;
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.25rem;
  height: 56px;
  background: white;
  border-bottom: 1px solid #e5e7eb;
  position: sticky;
  top: 0;
  z-index: 100;
  gap: 0.75rem;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  min-width: 0;
  flex: 1;
}

.hamburger {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: 44px;
  height: 44px;
  border: none;
  background: transparent;
  border-radius: 8px;
  color: #6b7280;
  cursor: pointer;
  &:hover { background: #f3f4f6; color: #111827; }
}

.page-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #1f2937;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-shrink: 0;
}

.content {
  flex: 1;
  padding: 1.25rem;
}

/* Bottom nav – hidden on desktop */
.bottom-nav { display: none; }

/* ─── Mobile (< 1024px) ─── */
@media (max-width: 1023px) {
  .main-content {
    margin-left: 0 !important;
  }

  .content {
    padding: 1rem;
    padding-bottom: calc(64px + env(safe-area-inset-bottom, 0px));
  }

  .bottom-nav {
    display: flex;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: calc(56px + env(safe-area-inset-bottom, 0px));
    padding-bottom: env(safe-area-inset-bottom, 0px);
    background: white;
    border-top: 1px solid #e5e7eb;
    z-index: 200;
    align-items: stretch;
  }

  .bnav-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 2px;
    color: #9ca3af;
    text-decoration: none;
    font-size: 0.6rem;
    font-weight: 500;
    min-height: 44px;
    transition: color 0.15s;

    &.router-link-active { color: #3b82f6; }

    span { line-height: 1.2; }
  }

  .bnav-scan {
    svg {
      background: #3b82f6;
      color: white;
      border-radius: 50%;
      padding: 5px;
      width: 38px;
      height: 38px;
    }
    color: #3b82f6;
  }
}
</style>
