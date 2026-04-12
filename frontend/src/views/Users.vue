<template>
  <div class="page">
    <div class="page-header">
      <h1>Benutzer</h1>
    </div>
    <div v-if="loading" class="loading">Wird geladen...</div>
    <div v-else class="card">
      <div v-for="user in users" :key="user.id" class="user-row">
        <span>{{ user.name }}</span>
        <span>{{ user.username }}</span>
        <span class="badge" :class="user.role === 'admin' ? 'badge-primary' : 'badge-success'">{{ user.role }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const toast = useToast()
const users = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await api.get('/users')
    users.value = res.data.data?.data || res.data.data
  } catch (e) {
    toast.error('Fehler beim Laden')
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; }
.user-row { display: flex; align-items: center; gap: 1rem; padding: 1rem; border-bottom: 1px solid #f3f4f6; }
.user-row:last-child { border-bottom: none; }
.loading { padding: 2rem; text-align: center; color: #6b7280; }
</style>