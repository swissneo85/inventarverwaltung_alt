<template>
  <div class="page">
    <div class="page-header">
      <h1>Einstellungen</h1>
    </div>
    <div class="card form-card">
      <h2>Profil</h2>
      <div class="form-group">
        <label>Name</label>
        <input v-model="form.name" type="text">
      </div>
      <div class="form-group">
        <label>E-Mail</label>
        <input v-model="form.email" type="email">
      </div>
      <button class="btn btn-primary" @click="saveProfile">Speichern</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'
import { useAuthStore } from '@/stores/auth'

const toast = useToast()
const authStore = useAuthStore()

const form = ref({
  name: '',
  email: ''
})

onMounted(() => {
  if (authStore.user) {
    form.value.name = authStore.user.name
    form.value.email = authStore.user.email || ''
  }
})

async function saveProfile() {
  try {
    await api.put('/profile', form.value)
    toast.success('Gespeichert')
  } catch (e) {
    toast.error('Fehler')
  }
}
</script>

<style scoped>
.page { max-width: 600px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; }
.form-card { padding: 1.5rem; }
.form-card h2 { font-size: 1rem; font-weight: 600; margin-bottom: 1rem; }
</style>