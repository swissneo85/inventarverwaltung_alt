import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false, title: 'Anmelden' }
  },
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true, title: 'Dashboard' }
  },
  {
    path: '/items',
    name: 'Items',
    component: () => import('@/views/Items.vue'),
    meta: { requiresAuth: true, title: 'Gegenstände' }
  },
  {
    path: '/items/create',
    name: 'ItemCreate',
    component: () => import('@/views/ItemEdit.vue'),
    meta: { requiresAuth: true, title: 'Neuer Gegenstand' }
  },
  {
    path: '/items/:id/edit',
    name: 'ItemEdit',
    component: () => import('@/views/ItemEdit.vue'),
    meta: { requiresAuth: true, title: 'Gegenstand bearbeiten' }
  },
  {
    path: '/items/:id',
    name: 'ItemDetail',
    component: () => import('@/views/ItemDetail.vue'),
    meta: { requiresAuth: true, title: 'Gegenstand' }
  },
  {
    path: '/rooms',
    name: 'Rooms',
    component: () => import('@/views/Rooms.vue'),
    meta: { requiresAuth: true, title: 'Räume' }
  },
  {
    path: '/rooms/:id',
    name: 'RoomDetail',
    component: () => import('@/views/RoomDetail.vue'),
    meta: { requiresAuth: true, title: 'Raum' }
  },
  {
    path: '/boxes',
    name: 'Boxes',
    component: () => import('@/views/Boxes.vue'),
    meta: { requiresAuth: true, title: 'Boxen' }
  },
  {
    path: '/boxes/:id',
    name: 'BoxDetail',
    component: () => import('@/views/BoxDetail.vue'),
    meta: { requiresAuth: true, title: 'Box' }
  },
  {
    path: '/inbox',
    name: 'Inbox',
    component: () => import('@/views/Inbox.vue'),
    meta: { requiresAuth: true, title: 'Inbox' }
  },
  {
    path: '/categories',
    name: 'Categories',
    component: () => import('@/views/Categories.vue'),
    meta: { requiresAuth: true, title: 'Kategorien' }
  },
  {
    path: '/scan/:token?',
    name: 'Scan',
    component: () => import('@/views/Scan.vue'),
    meta: { requiresAuth: true, title: 'QR-Code scannen' }
  },
  {
    path: '/users',
    name: 'Users',
    component: () => import('@/views/Users.vue'),
    meta: { requiresAuth: true, title: 'Benutzer', requiresAdmin: true }
  },
  {
    path: '/logs',
    name: 'Logs',
    component: () => import('@/views/Logs.vue'),
    meta: { requiresAuth: true, title: 'Login-Protokoll', requiresAdmin: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('@/views/Settings.vue'),
    meta: { requiresAuth: true, title: 'Einstellungen' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // Prüfen ob Authentifizierung erforderlich ist
  if (to.meta.requiresAuth !== false) {
    if (!authStore.isAuthenticated) {
      // Token prüfen
      const token = localStorage.getItem('token')
      if (token) {
        try {
          await authStore.fetchUser()
        } catch {
          localStorage.removeItem('token')
          return next({ name: 'Login', query: { redirect: to.fullPath } })
        }
      } else {
        return next({ name: 'Login', query: { redirect: to.fullPath } })
      }
    }
    
    // Admin-Route prüfen
    if (to.meta.requiresAdmin && !authStore.isAdmin) {
      return next({ name: 'Dashboard' })
    }
  }
  
  // Schon eingeloggt? Redirect von Login zu Dashboard
  if (to.name === 'Login' && authStore.isAuthenticated) {
    return next({ name: 'Dashboard' })
  }
  
  next()
})

export default router