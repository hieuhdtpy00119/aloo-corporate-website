<script setup>
import { reactive } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const form = reactive({
  name: '',
  phone: '',
  email: '',
  area: '',
  capital: '',
  note: '',
})

const submitForm = () => {
  alert(t('consultation.success'))
  Object.keys(form).forEach((key) => {
    form[key] = ''
  })
}
</script>

<template>
  <form class="grid gap-5 rounded-lg border border-avocado-100 bg-white p-6 shadow-sm" @submit.prevent="submitForm">
    <div class="grid gap-5 md:grid-cols-2">
      <label class="grid gap-2 text-sm font-bold text-slate-700">
        {{ t('consultation.fields.name') }}
        <input v-model="form.name" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
      </label>
      <label class="grid gap-2 text-sm font-bold text-slate-700">
        {{ t('consultation.fields.phone') }}
        <input v-model="form.phone" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
      </label>
    </div>
    <div class="grid gap-5 md:grid-cols-2">
      <label class="grid gap-2 text-sm font-bold text-slate-700">
        {{ t('consultation.fields.email') }}
        <input v-model="form.email" type="email" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
      </label>
      <label class="grid gap-2 text-sm font-bold text-slate-700">
        {{ t('consultation.fields.area') }}
        <input v-model="form.area" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
      </label>
    </div>
    <label class="grid gap-2 text-sm font-bold text-slate-700">
      {{ t('consultation.fields.capital') }}
      <input v-model="form.capital" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
    </label>
    <label class="grid gap-2 text-sm font-bold text-slate-700">
      {{ t('consultation.fields.note') }}
      <textarea v-model="form.note" rows="4" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
    </label>
    <button class="rounded-full bg-avocado-700 px-6 py-3 font-black text-white transition hover:bg-avocado-800">
      {{ t('consultation.submit') }}
    </button>
  </form>
</template>
