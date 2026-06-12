import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/items',
    name: 'Items',
    component: () => import('@/views/Items.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/items/new',
    name: 'ItemCreate',
    component: () => import('@/views/ItemEdit.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/items/:id/edit',
    name: 'ItemEdit',
    component: () => import('@/views/ItemEdit.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/items/:id',
    name: 'ItemDetail',
    component: () => import('@/views/ItemDetail.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/rooms',
    name: 'Rooms',
    component: () => import('@/views/Rooms.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/rooms/new',
    name: 'RoomCreate',
    component: () => import('@/views/RoomForm.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/rooms/:id/edit',
    name: 'RoomEdit',
    component: () => import('@/views/RoomForm.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/rooms/:id',
    name: 'RoomDetail',
    component: () => import('@/views/RoomDetail.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/boxes',
    name: 'Boxes',
    component: () => import('@/views/Boxes.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/boxes/new',
    name: 'BoxCreate',
    component: () => import('@/views/BoxEdit.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/boxes/:id/edit',
    name: 'BoxEdit',
    component: () => import('@/views/BoxEdit.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/boxes/:id',
    name: 'BoxDetail',
    component: () => import('@/views/BoxDetail.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/inbox',
    name: 'Inbox',
    component: () => import('@/views/Inbox.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/categories',
    name: 'Categories',
    component: () => import('@/views/Categories.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/persons',
    name: 'PersonList',
    component: () => import('@/views/persons/PersonList.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/persons/new',
    name: 'PersonCreate',
    component: () => import('@/views/persons/PersonForm.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/persons/:id/edit',
    name: 'PersonEdit',
    component: () => import('@/views/persons/PersonForm.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/categories/new',
    name: 'CategoryCreate',
    component: () => import('@/views/CategoryForm.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/categories/:id/edit',
    name: 'CategoryEdit',
    component: () => import('@/views/CategoryForm.vue'),
    meta: { requiresAuth: true, requiresEditor: true }
  },
  {
    path: '/scan/:token?',
    name: 'Scan',
    component: () => import('@/views/Scan.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/users',
    name: 'Users',
    component: () => import('@/views/users/UserList.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/users/new',
    name: 'UserCreate',
    component: () => import('@/views/users/UserForm.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/users/:id/edit',
    name: 'UserEdit',
    component: () => import('@/views/users/UserForm.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/logs',
    name: 'Logs',
    component: () => import('@/views/Logs.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('@/views/Settings.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    }
    return { top: 0 }
  }
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth !== false) {
    if (!authStore.isAuthenticated) {
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
    
    if (to.meta.requiresAdmin && !authStore.isAdmin) {
      return next({ name: 'Dashboard' })
    }

    if (to.meta.requiresEditor && !authStore.isEditor) {
      return next({ name: 'Dashboard' })
    }
  }
  
  if (to.name === 'Login' && authStore.isAuthenticated) {
    return next({ name: 'Dashboard' })
  }
  
  next()
})

export default router