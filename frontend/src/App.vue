<template>
  <div class="app" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
    <!-- Login Screen -->
    <div v-if="!isAuthenticated" class="login-container">
      <router-view />
    </div>

    <!-- Main App -->
    <template v-else>
      <Sidebar 
        :collapsed="sidebarCollapsed" 
        @toggle="toggleSidebar"
      />
      
      <main class="main-content">
        <header class="header">
          <div class="header-left">
            <button class="btn-icon" @click="toggleSidebar">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="3" y1="12" x2="21" y2="12"></line>
                <line x1="3" y1="6" x2="21" y2="6"></line>
                <line x1="3" y1="18" x2="21" y2="18"></line>
              </svg>
            </button>
            <h1 class="page-title">{{ pageTitle }}</h1>
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
    </template>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import Sidebar from '@/components/Sidebar.vue'
import UserMenu from '@/components/UserMenu.vue'
import GlobalSearch from '@/components/GlobalSearch.vue'

const route = useRoute()
const authStore = useAuthStore()

const sidebarCollapsed = ref(false)

const isAuthenticated = computed(() => authStore.isAuthenticated)

const pageTitle = computed(() => {
  return route.meta?.title || 'Inventarverwaltung'
})

function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
}
</script>

<style lang="scss" scoped>
.app {
  display: flex;
  min-height: 100vh;
  background-color: #f8f9fa;
}

.login-container {
  min-height: 100vh;
  width: 100%;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-left: 260px;
  transition: margin-left 0.3s ease;
}

.app.sidebar-collapsed .main-content {
  margin-left: 70px;
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.5rem;
  background: white;
  border-bottom: 1px solid #e5e7eb;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.page-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.btn-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border: none;
  background: transparent;
  cursor: pointer;
  border-radius: 8px;
  color: #6b7280;
  transition: all 0.2s;

  &:hover {
    background: #f3f4f6;
    color: #1f2937;
  }
}

.content {
  flex: 1;
  padding: 1.5rem;
  overflow-y: auto;
}

@media (max-width: 768px) {
  .main-content {
    margin-left: 0;
  }
  
  .header {
    padding: 0.75rem 1rem;
  }
  
  .content {
    padding: 1rem;
  }
}
</style>