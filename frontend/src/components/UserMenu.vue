<template>
  <div class="user-menu" ref="menuRef">
    <button class="user-btn" @click="isOpen = !isOpen">
      <div class="user-avatar">
        {{ userInitials }}
      </div>
      <span class="user-name">{{ userName }}</span>
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <polyline points="6 9 12 15 18 9"></polyline>
      </svg>
    </button>
    
    <div v-if="isOpen" class="menu-dropdown">
      <div class="menu-header">
        <div class="user-avatar large">
          {{ userInitials }}
        </div>
        <div class="user-info">
          <div class="user-full-name">{{ authStore.user?.name }}</div>
          <div class="user-role">
            <span :class="['role-badge', authStore.user?.role]">
              {{ roleLabel }}
            </span>
          </div>
        </div>
      </div>
      
      <div class="menu-divider"></div>
      
      <div class="menu-items">
        <router-link to="/settings" class="menu-item" @click="isOpen = false">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="3"></circle>
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
          </svg>
          Einstellungen
        </router-link>
        
        <button class="menu-item logout" @click="handleLogout">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
            <polyline points="16 17 21 12 16 7"></polyline>
            <line x1="21" y1="12" x2="9" y2="12"></line>
          </svg>
          Abmelden
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const menuRef = ref(null)
const isOpen = ref(false)

const userInitials = computed(() => {
  const name = authStore.user?.name || ''
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
})

const userName = computed(() => {
  return authStore.user?.username || ''
})

const roleLabel = computed(() => {
  const roles = {
    admin: 'Administrator',
    editor: 'Bearbeiter',
    viewer: 'Betrachter',
  }
  return roles[authStore.user?.role] || authStore.user?.role || 'Benutzer'
})

async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}

function handleClickOutside(event) {
  if (menuRef.value && !menuRef.value.contains(event.target)) {
    isOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style lang="scss" scoped>
.user-menu {
  position: relative;
}

.user-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  border: none;
  background: #f3f4f6;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover {
    background: #e5e7eb;
  }
}

.user-avatar {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #3b82f6;
  color: white;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 600;
  
  &.large {
    width: 48px;
    height: 48px;
    font-size: 1rem;
  }
}

.user-name {
  font-size: 0.875rem;
  font-weight: 500;
  color: #1f2937;
  
  @media (max-width: 640px) {
    display: none;
  }
}

.menu-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  width: 280px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  overflow: hidden;
}

.menu-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #f8fafc;
}

.user-info {
  flex: 1;
}

.user-full-name {
  font-weight: 600;
  color: #1f2937;
}

.user-role {
  margin-top: 0.25rem;
}

.role-badge {
  padding: 0.125rem 0.5rem;
  font-size: 0.75rem;
  font-weight: 500;
  border-radius: 4px;
  
  &.admin {
    background: #fef3c7;
    color: #92400e;
  }
  
  &.editor {
    background: #dcfce7;
    color: #166534;
  }
  
  &.viewer {
    background: #f3f4f6;
    color: #4b5563;
  }
}

.menu-divider {
  height: 1px;
  background: #e5e7eb;
}

.menu-items {
  padding: 0.5rem;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  border-radius: 8px;
  font-size: 0.875rem;
  color: #374151;
  text-decoration: none;
  cursor: pointer;
  transition: background 0.15s;
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  
  &:hover {
    background: #f3f4f6;
  }
  
  &.logout {
    color: #dc2626;
    
    &:hover {
      background: #fef2f2;
    }
  }
}
</style>