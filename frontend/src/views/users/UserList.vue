<template>
  <div class="users-page">
    <div class="page-header">
      <h1>Benutzer</h1>
      <button class="btn btn-primary" @click="$router.push({ name: 'UserCreate' })">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        Neuer Benutzer
      </button>
    </div>

    <div v-if="loading" class="empty-state">Wird geladen…</div>

    <div v-else-if="users.length === 0" class="empty-state">
      <p>Noch keine Benutzer vorhanden.</p>
    </div>

    <div v-else class="list-card card">
      <div
        v-for="user in users"
        :key="user.id"
        :class="['user-row', { 'user-row--inactive': !user.active }]"
      >
        <div class="user-info">
          <div class="user-avatar">{{ initials(user.name) }}</div>
          <div class="user-details">
            <span class="user-name">{{ user.name }}</span>
            <span class="user-username">@{{ user.username }}</span>
          </div>
          <span :class="getRoleBadgeClass(user.role)">{{ getRoleLabel(user.role) }}</span>
          <span v-if="!user.active" class="inactive-badge">Inaktiv</span>
        </div>
        <div class="user-actions">
          <button
            class="row-btn"
            title="Bearbeiten"
            @click="$router.push({ name: 'UserEdit', params: { id: user.id } })"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
            </svg>
          </button>
          <button
            class="row-btn row-btn--danger"
            title="Löschen"
            :disabled="user.id === currentUserId"
            @click="confirmDelete(user)"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="3 6 5 6 21 6"/>
              <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>
              <path d="M10 11v6"/><path d="M14 11v6"/>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Delete confirmation -->
    <div v-if="deleteTarget" class="confirm-backdrop" @click.self="deleteTarget = null">
      <div class="confirm-dialog">
        <p>Benutzer <strong>{{ deleteTarget.name }}</strong> wirklich löschen?</p>
        <p class="confirm-hint">Diese Aktion kann nicht rückgängig gemacht werden.</p>
        <div class="confirm-actions">
          <button class="btn btn-secondary" @click="deleteTarget = null">Abbrechen</button>
          <button class="btn-danger" :disabled="deleting" @click="doDelete">
            {{ deleting ? '…' : 'Löschen' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'
import { useAuthStore } from '@/stores/auth'

const toast = useToast()
const authStore = useAuthStore()
const users = ref([])
const loading = ref(true)
const deleteTarget = ref(null)
const deleting = ref(false)

const currentUserId = computed(() => authStore.user?.id)

async function load() {
  try {
    const res = await api.get('/users')
    const data = res.data.data
    users.value = data?.data ?? data
  } catch {
    toast.error('Fehler beim Laden der Benutzer')
  } finally {
    loading.value = false
  }
}

onMounted(load)

function initials(name) {
  return (name || '')
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

function getRoleLabel(role) {
  return { admin: 'Admin', editor: 'Bearbeiter', viewer: 'Leser' }[role] || role
}

function getRoleBadgeClass(role) {
  const base = 'role-badge'
  return {
    admin:  `${base} badge-blue`,
    editor: `${base} badge-green`,
    viewer: `${base} badge-gray`,
  }[role] || `${base} badge-gray`
}

function confirmDelete(user) {
  deleteTarget.value = user
}

async function doDelete() {
  if (deleting.value) return
  deleting.value = true
  try {
    await api.delete(`/users/${deleteTarget.value.id}`)
    toast.success('Benutzer gelöscht')
    users.value = users.value.filter(u => u.id !== deleteTarget.value.id)
    deleteTarget.value = null
  } catch {
    // interceptor shows error
  } finally {
    deleting.value = false
  }
}
</script>

<style scoped>
.users-page { max-width: 900px; margin: 0 auto; }

.page-header {
  display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem;
  h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
}

.empty-state {
  padding: 3rem; text-align: center; color: #6b7280;
  display: flex; flex-direction: column; align-items: center; gap: 1rem;
  p { margin: 0; }
}

.list-card { overflow: hidden; }

.user-row {
  display: flex; align-items: center; padding: 0.875rem 1rem;
  border-bottom: 1px solid #f3f4f6; transition: background 0.12s;
  &:last-child { border-bottom: none; }
  &:hover { background: #f9fafb; }
}

.user-row--inactive { opacity: 0.6; }

.user-info {
  flex: 1; min-width: 0; display: flex; align-items: center; gap: 0.75rem; flex-wrap: wrap;
}

.user-avatar {
  width: 36px; height: 36px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  background: #3b82f6; color: white; border-radius: 8px;
  font-size: 0.8rem; font-weight: 600;
}

.user-details { display: flex; flex-direction: column; min-width: 0; }
.user-name { font-weight: 600; font-size: 0.9rem; color: #111827; }
.user-username { font-size: 0.78rem; color: #6b7280; }

.role-badge {
  padding: 0.15rem 0.55rem; border-radius: 99px; font-size: 0.72rem; font-weight: 600;
  white-space: nowrap;
}
.badge-blue   { background: #dbeafe; color: #1e40af; }
.badge-green  { background: #dcfce7; color: #166534; }
.badge-gray   { background: #f3f4f6; color: #4b5563; }

.inactive-badge {
  display: inline-block; padding: 0.1rem 0.45rem;
  background: #f3f4f6; color: #6b7280; border: 1px solid #d1d5db;
  border-radius: 99px; font-size: 0.7rem; font-weight: 500;
}

.user-actions { display: flex; gap: 0.25rem; margin-left: auto; flex-shrink: 0; }

.row-btn {
  display: flex; align-items: center; justify-content: center;
  width: 30px; height: 30px; border: none; background: none;
  border-radius: 6px; color: #9ca3af; cursor: pointer; transition: all 0.15s;
  &:hover:not(:disabled) { background: #eff6ff; color: #3b82f6; }
  &:disabled { opacity: 0.3; cursor: not-allowed; }
}
.row-btn--danger:hover:not(:disabled) { background: #fee2e2 !important; color: #dc2626 !important; }

.btn-danger {
  display: inline-flex; align-items: center; gap: 0.4rem;
  padding: 0.5rem 0.875rem; background: #fee2e2; color: #991b1b;
  border: 1px solid #fca5a5; border-radius: 8px; font-size: 0.875rem;
  font-weight: 500; cursor: pointer; transition: background 0.15s;
  &:hover:not(:disabled) { background: #fecaca; }
  &:disabled { opacity: 0.5; cursor: not-allowed; }
}

.confirm-backdrop {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 500;
  display: flex; align-items: center; justify-content: center;
}
.confirm-dialog {
  background: white; border-radius: 12px; padding: 1.5rem; margin: 1rem;
  min-width: 280px; text-align: center; box-shadow: 0 8px 32px rgba(0,0,0,0.2);
  p { margin: 0 0 0.5rem; font-size: 1rem; color: #111827; }
  p:last-of-type { margin-bottom: 1.25rem; }
}
.confirm-hint { font-size: 0.82rem !important; color: #9ca3af !important; }
.confirm-actions { display: flex; gap: 0.75rem; justify-content: center; }
</style>
