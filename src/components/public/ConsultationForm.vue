<script setup>
import { reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'
import { createFranchiseRegistration } from '../../services/franchiseRegistrationService'
import { Send } from 'lucide-vue-next'

const { t } = useI18n()
const store = useAppStore()
const toast = useToastStore()
const isSubmitting = ref(false)

const form = reactive({
  name: '',
  phone: '',
  email: '',
  area: '',
  capital: '',
  note: '',
})

const resetForm = () => {
  Object.keys(form).forEach((key) => {
    form[key] = ''
  })
}

const submitForm = async () => {
  if (isSubmitting.value) return
  isSubmitting.value = true

  const payload = {
    fullName: form.name,
    phone: form.phone,
    email: form.email,
    province: form.area,
    expectedBudget: Number(String(form.capital).replace(/\D/g, '')) || 0,
    note: form.note,
  }

  try {
    const { data } = await createFranchiseRegistration(payload)
    store.addRegistration(data)
    toast.success(t('consultation.success'))
    resetForm()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không gửi được đăng ký tư vấn. Vui lòng thử lại sau.')
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <form class="grid gap-5 rounded-3xl border border-avocado-100/30 bg-white p-6 sm:p-8 shadow-md" @submit.prevent="submitForm">
    <div class="grid gap-5 md:grid-cols-2">
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ t('consultation.fields.name') }} *
        <input v-model="form.name" required class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" />
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ t('consultation.fields.phone') }} *
        <input v-model="form.phone" required class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" />
      </label>
    </div>
    <div class="grid gap-5 md:grid-cols-2">
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ t('consultation.fields.email') }}
        <input v-model="form.email" type="email" class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" />
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ t('consultation.fields.area') }} *
        <input v-model="form.area" required class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" />
      </label>
    </div>
    <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ t('consultation.fields.capital') }} *
      <input v-model="form.capital" required class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" placeholder="Ví dụ: 300,000,000" />
    </label>
    <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ t('consultation.fields.note') }}
      <textarea v-model="form.note" rows="4" class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" placeholder="Nhu cầu hoặc thông điệp chi tiết của bạn..."></textarea>
    </label>
    <div class="pt-3">
      <button 
        class="w-full rounded-full bg-avocado-600 px-6 py-4 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 transition duration-300 disabled:cursor-not-allowed disabled:opacity-60 flex items-center justify-center gap-2 shadow-lg shadow-avocado-600/10" 
        :disabled="isSubmitting"
      >
        <Send class="h-4 w-4" />
        {{ isSubmitting ? 'Đang gửi thông tin...' : t('consultation.submit') }}
      </button>
    </div>
  </form>
</template>

