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
import UserLoginView from '../views/public/UserLoginView.vue'
import UserProfileView from '../views/public/UserProfileView.vue'
import UserChangePasswordView from '../views/public/UserChangePasswordView.vue'
import NotFoundView from '../views/public/NotFoundView.vue'
import AdminLoginView from '../views/admin/AdminLoginView.vue'
import AdminDashboardView from '../views/admin/AdminDashboardView.vue'
import AdminProductsView from '../views/admin/AdminProductsView.vue'
import AdminRegistrationsView from '../views/admin/AdminRegistrationsView.vue'
import AdminArticlesView from '../views/admin/AdminArticlesView.vue'
import AdminArticleEditorView from '../views/admin/AdminArticleEditorView.vue'
import AdminCategoriesView from '../views/admin/AdminCategoriesView.vue'
import AdminFranchiseContentView from '../views/admin/AdminFranchiseContentView.vue'
import AdminLocationsView from '../views/admin/AdminLocationsView.vue'
import AdminProfileView from '../views/admin/AdminProfileView.vue'
import AdminChangePasswordView from '../views/admin/AdminChangePasswordView.vue'
import { resolveAuthRedirect } from './authGuard'

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
        { path: 'login', name: 'user-login', component: UserLoginView },
        { path: 'profile', name: 'user-profile', component: UserProfileView, meta: { requiresUser: true } },
        {
          path: 'change-password',
          name: 'user-change-password',
          component: UserChangePasswordView,
          meta: { requiresUser: true },
        },
      ],
    },
    { path: '/admin/login', name: 'admin-login', component: AdminLoginView },
    {
      path: '/admin',
      component: AdminLayout,
      children: [
        { path: '', name: 'admin-dashboard', component: AdminDashboardView },
        { path: 'products', name: 'admin-products', component: AdminProductsView },
        { path: 'articles', name: 'admin-articles', component: AdminArticlesView },
        { path: 'articles/new', name: 'admin-article-new', component: AdminArticleEditorView },
        { path: 'articles/:id/edit', name: 'admin-article-edit', component: AdminArticleEditorView },
        { path: 'categories', name: 'admin-categories', component: AdminCategoriesView },
        { path: 'posts', redirect: '/admin/articles' },
        { path: 'posts/new', redirect: '/admin/articles/new' },
        { path: 'posts/:id/edit', redirect: (to) => `/admin/articles/${to.params.id}/edit` },
        { path: 'locations', name: 'admin-locations', component: AdminLocationsView },
        { path: 'registrations', name: 'admin-registrations', component: AdminRegistrationsView },
        { path: 'profile', name: 'admin-profile', component: AdminProfileView },
        { path: 'change-password', name: 'admin-change-password', component: AdminChangePasswordView },
        {
          path: 'franchise-content',
          name: 'admin-franchise-content',
          component: AdminFranchiseContentView,
        },
        { path: ':pathMatch(.*)*', name: 'admin-not-found', component: NotFoundView },
      ],
    },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFoundView },
  ],
})

router.beforeEach((to) => resolveAuthRedirect(to))

export default router
