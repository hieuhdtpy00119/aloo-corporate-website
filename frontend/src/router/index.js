import { createRouter, createWebHistory } from 'vue-router'
import PublicLayout from '../layouts/PublicLayout.vue'
import AdminLayout from '../layouts/AdminLayout.vue'
import HomeView from '../views/public/HomeView.vue'
import AboutView from '../views/public/AboutView.vue'
import ProductsView from '../views/public/ProductsView.vue'
import ProductDetailView from '../views/public/ProductDetailView.vue'
import FranchiseView from '../views/public/FranchiseView.vue'
import ProcessView from '../views/public/ProcessView.vue'
import CostView from '../views/public/CostView.vue'
import ConsultationView from '../views/public/ConsultationView.vue'
import ContactView from '../views/public/ContactView.vue'
import LocationsView from '../views/public/LocationsView.vue'
import StoreDetailView from '../views/public/StoreDetailView.vue'
import BlogView from '../views/public/BlogView.vue'
import BlogDetailView from '../views/public/BlogDetailView.vue'
import OAuthCallbackView from '../views/public/OAuthCallbackView.vue'
import NotFoundView from '../views/public/NotFoundView.vue'
import AdminLoginView from '../views/admin/AdminLoginView.vue'
import AdminDashboardView from '../views/admin/AdminDashboardView.vue'
import AdminProductsView from '../views/admin/AdminProductsView.vue'
import AdminFeedbackView from '../views/admin/AdminFeedbackView.vue'
import AdminRegistrationsView from '../views/admin/AdminRegistrationsView.vue'
import AdminArticlesView from '../views/admin/AdminArticlesView.vue'
import AdminArticleEditorView from '../views/admin/AdminArticleEditorView.vue'
import AdminCategoriesView from '../views/admin/AdminCategoriesView.vue'
import AdminFranchiseContentView from '../views/admin/AdminFranchiseContentView.vue'
import AdminLocationsView from '../views/admin/AdminLocationsView.vue'
import AdminProfileView from '../views/admin/AdminProfileView.vue'
import AdminChangePasswordView from '../views/admin/AdminChangePasswordView.vue'
import AdminAccountsView from '../views/admin/AdminAccountsView.vue'
import AdminHomeSectionsView from '../views/admin/AdminHomeSectionsView.vue'
import { resolveAuthRedirect } from './authGuard'
import { trackPageview } from '../services/analyticsService'
import { routeSeo, setSeoMeta } from '../services/seoService'

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) return savedPosition
    if (to.hash) {
      return {
        el: to.hash,
        top: 96,
        behavior: 'smooth',
      }
    }
    return { top: 0, left: 0 }
  },
  routes: [
    {
      path: '/',
      component: PublicLayout,
      children: [
        { path: '', name: 'home', component: HomeView },
        { path: 'about', name: 'about', component: AboutView },
        { path: 'products', name: 'products', component: ProductsView },
        { path: 'products/:slug', name: 'product-detail', component: ProductDetailView },
        { path: 'franchise', name: 'franchise', component: FranchiseView },
        { path: 'process', name: 'process', component: ProcessView },
        { path: 'cost', name: 'cost', component: CostView },
        { path: 'locations', name: 'locations', component: LocationsView },
        { path: 'locations/:slug', name: 'store-detail', component: StoreDetailView },
        { path: 'blog', name: 'blog', component: BlogView },
        { path: 'blog/:slug', name: 'blog-detail', component: BlogDetailView },
        { path: 'consultation', name: 'consultation', component: ConsultationView },
        { path: 'contact', name: 'contact', component: ContactView },
      ],
    },
    { path: '/oauth/callback', name: 'oauth-callback', component: OAuthCallbackView },
    { path: '/admin/login', name: 'admin-login', component: AdminLoginView },
    {
      path: '/admin',
      component: AdminLayout,
      children: [
        { path: '', name: 'admin-dashboard', component: AdminDashboardView },
        { path: 'products', name: 'admin-products', component: AdminProductsView },
        { path: 'feedbacks', name: 'admin-feedbacks', component: AdminFeedbackView },
        { path: 'home-sections', name: 'admin-home-sections', component: AdminHomeSectionsView },
        { path: 'articles', name: 'admin-articles', component: AdminArticlesView },
        { path: 'articles/new', name: 'admin-article-new', component: AdminArticleEditorView },
        { path: 'articles/:id/edit', name: 'admin-article-edit', component: AdminArticleEditorView },
        { path: 'categories', name: 'admin-categories', component: AdminCategoriesView },
        { path: 'posts', redirect: '/admin/articles' },
        { path: 'posts/new', redirect: '/admin/articles/new' },
        { path: 'posts/:id/edit', redirect: (to) => `/admin/articles/${to.params.id}/edit` },
        { path: 'locations', name: 'admin-locations', component: AdminLocationsView },
        { path: 'registrations', name: 'admin-registrations', component: AdminRegistrationsView },
        { path: 'accounts', name: 'admin-accounts', component: AdminAccountsView },
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

router.afterEach((to) => {
  const exactSeo = routeSeo[to.path]
  if (exactSeo) setSeoMeta(exactSeo)
  trackPageview(to.fullPath)
})

export default router

