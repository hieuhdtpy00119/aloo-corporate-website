import { createRouter, createWebHistory } from 'vue-router'
import PublicLayout from '../layouts/PublicLayout.vue'
import AdminLayout from '../layouts/AdminLayout.vue'
import HomeView from '../views/public/HomeView.vue'
import AboutView from '../views/public/AboutView.vue'
import ProductsView from '../views/public/ProductsView.vue'
import FranchiseView from '../views/public/FranchiseView.vue'
import ProcessView from '../views/public/ProcessView.vue'
import CostView from '../views/public/CostView.vue'
import ConsultationView from '../views/public/ConsultationView.vue'
import ContactView from '../views/public/ContactView.vue'
import LocationsView from '../views/public/LocationsView.vue'
import BlogView from '../views/public/BlogView.vue'
import BlogDetailView from '../views/public/BlogDetailView.vue'
import AdminLoginView from '../views/admin/AdminLoginView.vue'
import AdminDashboardView from '../views/admin/AdminDashboardView.vue'
import AdminProductsView from '../views/admin/AdminProductsView.vue'
import AdminRegistrationsView from '../views/admin/AdminRegistrationsView.vue'
import AdminBannersView from '../views/admin/AdminBannersView.vue'
import AdminPostsView from '../views/admin/AdminPostsView.vue'
import AdminFranchiseContentView from '../views/admin/AdminFranchiseContentView.vue'
import AdminLocationsView from '../views/admin/AdminLocationsView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: PublicLayout,
      children: [
        { path: '', name: 'home', component: HomeView },
        { path: 'about', name: 'about', component: AboutView },
        { path: 'products', name: 'products', component: ProductsView },
        { path: 'franchise', name: 'franchise', component: FranchiseView },
        { path: 'process', name: 'process', component: ProcessView },
        { path: 'cost', name: 'cost', component: CostView },
        { path: 'locations', name: 'locations', component: LocationsView },
        { path: 'blog', name: 'blog', component: BlogView },
        { path: 'blog/:id', name: 'blog-detail', component: BlogDetailView },
        { path: 'consultation', name: 'consultation', component: ConsultationView },
        { path: 'contact', name: 'contact', component: ContactView },
      ],
    },
    { path: '/admin/login', name: 'admin-login', component: AdminLoginView },
    {
      path: '/admin',
      component: AdminLayout,
      children: [
        { path: '', name: 'admin-dashboard', component: AdminDashboardView },
        { path: 'products', name: 'admin-products', component: AdminProductsView },
        { path: 'banners', name: 'admin-banners', component: AdminBannersView },
        { path: 'posts', name: 'admin-posts', component: AdminPostsView },
        { path: 'locations', name: 'admin-locations', component: AdminLocationsView },
        { path: 'registrations', name: 'admin-registrations', component: AdminRegistrationsView },
        {
          path: 'franchise-content',
          name: 'admin-franchise-content',
          component: AdminFranchiseContentView,
        },
      ],
    },
  ],
})

router.beforeEach((to) => {
  const token = localStorage.getItem('admin_token')
  const isAdminLogin = to.path === '/admin/login'
  const isAdminRoute = to.path.startsWith('/admin') && !isAdminLogin

  if (isAdminLogin) {
    return true
  }

  if (isAdminRoute && !token) {
    return '/admin/login'
  }

  return true
})

export default router
