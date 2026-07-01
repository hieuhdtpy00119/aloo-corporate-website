import { createRouter, createWebHistory } from 'vue-router'

import PublicLayout from '../layouts/PublicLayout.vue'

import AdminLayout from '../layouts/AdminLayout.vue'

import HomeView from '../views/public/HomeView.vue'

import AboutView from '../views/public/AboutView.vue'

import ProductsView from '../views/public/ProductsView.vue'

import ProductDetailView from '../views/public/ProductDetailView.vue'

import FranchiseView from '../views/public/FranchiseView.vue'

import ConsultationView from '../views/public/ConsultationView.vue'

import ContactView from '../views/public/ContactView.vue'

import LocationsView from '../views/public/LocationsView.vue'

import StoreDetailView from '../views/public/StoreDetailView.vue'

import BlogView from '../views/public/BlogView.vue'

import BlogDetailView from '../views/public/BlogDetailView.vue'

import OAuthCallbackView from '../views/public/OAuthCallbackView.vue'

import AccountView from '../views/public/AccountView.vue'

import NotFoundView from '../views/public/NotFoundView.vue'

import AdminLoginView from '../views/admin/AdminLoginView.vue'

import AdminDashboardView from '../views/admin/AdminDashboardView.vue'

import AdminProductsView from '../views/admin/AdminProductsView.vue'

import AdminFeedbackView from '../views/admin/AdminFeedbackView.vue'

import AdminProductReviewsView from '../views/admin/AdminProductReviewsView.vue'

import AdminRegistrationsView from '../views/admin/AdminRegistrationsView.vue'

import AdminArticlesView from '../views/admin/AdminArticlesView.vue'

import AdminArticleEditorView from '../views/admin/AdminArticleEditorView.vue'

import AdminCategoriesView from '../views/admin/AdminCategoriesView.vue'

import AdminLocationsView from '../views/admin/AdminLocationsView.vue'

import AdminProfileView from '../views/admin/AdminProfileView.vue'

import AdminAccountsView from '../views/admin/AdminAccountsView.vue'

import AdminAuditLogsView from '../views/admin/AdminAuditLogsView.vue'

import AdminHomeSectionsView from '../views/admin/AdminHomeSectionsView.vue'

import AdminFranchiseContentView from '../views/admin/AdminFranchiseContentView.vue'

import AdminChatView from '../views/admin/AdminChatView.vue'

import { adminPaths } from '../constants/adminPaths'

import { resolveAuthRedirect } from './authGuard'

import { canAccessAdminPath, canAccessAdminSession } from '../utils/adminAccess'

import { trackPageview } from '../services/analyticsService'

import { applyRouteSeo } from '../services/seoService'

import i18n from '../plugins/i18n'



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

        { path: 'process', redirect: { path: '/franchise', hash: '#process' } },

        { path: 'cost', redirect: { path: '/franchise', hash: '#investment' } },

        { path: 'locations', name: 'locations', component: LocationsView },

        { path: 'locations/:slug', name: 'store-detail', component: StoreDetailView },

        { path: 'blog', name: 'blog', component: BlogView },

        { path: 'blog/:slug', name: 'blog-detail', component: BlogDetailView },

        { path: 'consultation', name: 'consultation', component: ConsultationView },

        { path: 'contact', name: 'contact', component: ContactView },

        { path: 'account', name: 'account', component: AccountView },

      ],

    },

    { path: '/oauth/callback', name: 'oauth-callback', component: OAuthCallbackView },

    { path: '/login', name: 'login', component: AdminLoginView },

    { path: '/admin/login', redirect: '/login' },

    {

      path: '/admin',

      component: AdminLayout,

      children: [

        { path: '', name: 'admin-dashboard', component: AdminDashboardView, meta: { adminScope: 'dashboard' } },

        { path: 'content/home-sections', name: 'admin-content-home-sections', component: AdminHomeSectionsView, meta: { adminScope: 'content' } },

        { path: 'content/products', name: 'admin-content-products', component: AdminProductsView, meta: { adminScope: 'content' } },

        { path: 'content/franchise', name: 'admin-content-franchise', component: AdminFranchiseContentView, meta: { adminScope: 'content' } },

        { path: 'content/articles', name: 'admin-content-articles', component: AdminArticlesView, meta: { adminScope: 'content' } },

        { path: 'content/articles/categories', name: 'admin-content-article-categories', component: AdminCategoriesView, meta: { adminScope: 'content' } },

        { path: 'content/articles/new', name: 'admin-content-article-new', component: AdminArticleEditorView, meta: { adminScope: 'content' } },

        { path: 'content/articles/:id/edit', name: 'admin-content-article-edit', component: AdminArticleEditorView, meta: { adminScope: 'content' } },

        { path: 'stores/locations', name: 'admin-stores-locations', component: AdminLocationsView, meta: { adminScope: 'stores' } },

        { path: 'crm/feedbacks', name: 'admin-crm-feedbacks', component: AdminFeedbackView, meta: { adminScope: 'crm' } },

        { path: 'crm/product-reviews', name: 'admin-crm-product-reviews', component: AdminProductReviewsView, meta: { adminScope: 'crm' } },

        { path: 'crm/leads', name: 'admin-crm-leads', component: AdminRegistrationsView, meta: { adminScope: 'crm' } },

        { path: 'crm/live-chat', name: 'admin-crm-live-chat', component: AdminChatView, meta: { adminScope: 'crm' } },

        { path: 'system/accounts', name: 'admin-system-accounts', component: AdminAccountsView, meta: { adminScope: 'system' } },

        { path: 'system/audit-logs', name: 'admin-system-audit-logs', component: AdminAuditLogsView, meta: { adminScope: 'system' } },

        { path: 'profile', name: 'admin-profile', component: AdminProfileView },

        { path: 'home-sections', redirect: adminPaths.content.homeSections },

        { path: 'products', redirect: adminPaths.content.products },

        { path: 'franchise-content', redirect: adminPaths.content.franchise },

        { path: 'articles', redirect: adminPaths.content.articles },

        { path: 'articles/categories', redirect: adminPaths.content.articleCategories },

        { path: 'articles/new', redirect: adminPaths.content.articleNew },

        { path: 'articles/:id/edit', redirect: (to) => adminPaths.content.articleEdit(to.params.id) },

        { path: 'categories', redirect: adminPaths.content.articleCategories },

        { path: 'locations', redirect: adminPaths.stores.locations },

        { path: 'feedbacks', redirect: adminPaths.crm.feedbacks },

        { path: 'product-reviews', redirect: adminPaths.crm.productReviews },

        { path: 'registrations', redirect: adminPaths.crm.leads },

        { path: 'live-chat', redirect: adminPaths.crm.liveChat },

        { path: 'accounts', redirect: adminPaths.system.accounts },

        { path: 'posts', redirect: adminPaths.content.articles },

        { path: 'posts/new', redirect: adminPaths.content.articleNew },

        { path: 'posts/:id/edit', redirect: (to) => adminPaths.content.articleEdit(to.params.id) },

        { path: 'change-password', redirect: { path: adminPaths.profile, query: { tab: 'security' } } },

        { path: ':pathMatch(.*)*', name: 'admin-not-found', component: NotFoundView },

      ],

    },

    { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFoundView },

  ],

})



router.beforeEach((to) => {

  const authRedirect = resolveAuthRedirect(to)

  if (authRedirect !== true) return authRedirect



  if (to.path.startsWith('/admin') && to.path !== '/login') {

    const permissions = canAccessAdminSession()

    if (!canAccessAdminPath(to.path, permissions)) {
      return { path: adminPaths.dashboard, query: { denied: to.path } }
    }

  }



  return true

})



router.afterEach((to) => {

  applyRouteSeo(to.path, i18n.global.t)

  trackPageview(to.fullPath)

})

const enforceAuthRedirect = () => {
  const redirect = resolveAuthRedirect(router.currentRoute.value)
  if (redirect !== true) {
    router.push(redirect)
  }
}

if (typeof window !== 'undefined') {
  window.addEventListener('aloo-auth-change', enforceAuthRedirect)
}

export default router


