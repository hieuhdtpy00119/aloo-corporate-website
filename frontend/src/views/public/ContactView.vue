<script setup>
import { reactive, ref } from 'vue'
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useI18n } from 'vue-i18n'
import { Phone, Mail, MapPin, Sparkles, Send } from 'lucide-vue-next'
import { contactMessageService } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const { t } = useI18n()
const toast = useToastStore()
const isSubmitting = ref(false)

const form = reactive({
  fullName: '',
  phone: '',
  email: '',
  province: '',
  message: '',
})

const errors = reactive({
  fullName: '',
  phone: '',
  email: '',
  message: '',
})

const phonePattern = /^[0-9+() .-]{8,40}$/
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

function resetErrors() {
  errors.fullName = ''
  errors.phone = ''
  errors.email = ''
  errors.message = ''
}

function validateForm() {
  resetErrors()

  if (!form.fullName.trim()) {
    errors.fullName = 'Vui lòng nhập họ tên'
  }

  if (!form.phone.trim()) {
    errors.phone = 'Vui lòng nhập số điện thoại'
  } else if (!phonePattern.test(form.phone.trim())) {
    errors.phone = 'Số điện thoại không đúng định dạng'
  }

  if (form.email.trim() && !emailPattern.test(form.email.trim())) {
    errors.email = 'Email không đúng định dạng'
  }

  if (!form.message.trim()) {
    errors.message = 'Vui lòng nhập nội dung cần hỗ trợ'
  }

  return !errors.fullName && !errors.phone && !errors.email && !errors.message
}

function resetForm() {
  form.fullName = ''
  form.phone = ''
  form.email = ''
  form.province = ''
  form.message = ''
  resetErrors()
}

async function submitContact() {
  if (isSubmitting.value) return
  if (!validateForm()) {
    toast.error('Vui lòng kiểm tra lại thông tin liên hệ')
    return
  }

  isSubmitting.value = true
  try {
    await contactMessageService.create({
      fullName: form.fullName.trim(),
      phone: form.phone.trim(),
      email: form.email.trim() || null,
      subject: form.province.trim() || 'Liên hệ website',
      message: form.message.trim(),
    })
    toast.success('Đã gửi liên hệ thành công')
    resetForm()
  } catch (error) {
    toast.error(error?.response?.data?.message || 'Không gửi được liên hệ, vui lòng thử lại')
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <main class="bg-[#faf8f2] text-avocado-950 pb-20 min-h-screen">
    <!-- Header Hero block -->
    <div class="relative bg-avocado-950 text-white overflow-hidden py-20 px-4 sm:px-6 lg:px-8 text-center">
      <div class="absolute inset-0 opacity-15">
        <img
          src="https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO store map"
          class="h-full w-full object-cover"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-avocado-950/90"></div>
      <div class="relative max-w-3xl mx-auto space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          Liên hệ ALOO
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Kết Nối Với Chúng Tôi</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Chúng tôi luôn sẵn sàng lắng nghe mọi ý kiến đóng góp, thắc mắc cũng như yêu cầu hợp tác từ quý khách.
        </p>
      </div>
    </div>

    <!-- Main Section -->
    <section class="max-w-6xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('contact.eyebrow')"
        :title="t('contact.title')"
        :description="t('contact.description')"
      />
      <div class="mx-auto grid max-w-5xl gap-6 md:grid-cols-3 mt-10">
        <!-- Phone card -->
        <div class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <Phone class="h-5 w-5" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ t('footer.hotline') }}</h3>
            <p class="mt-4 text-sm text-slate-500 font-semibold leading-relaxed">0900 888 168</p>
          </div>
        </div>

        <!-- Email card -->
        <div class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <Mail class="h-5 w-5" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ t('footer.email') }}</h3>
            <p class="mt-4 text-sm text-slate-500 font-semibold leading-relaxed">franchise@aloo.vn</p>
          </div>
        </div>

        <!-- Address card -->
        <div class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <MapPin class="h-5 w-5" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ t('footer.address') }}</h3>
            <p class="mt-4 text-sm text-slate-500 leading-relaxed">{{ t('footer.addressValue') }}</p>
          </div>
        </div>
      </div>

      <!-- Contact form -->
      <div class="mt-12 grid gap-8 rounded-[2rem] border border-avocado-100/45 bg-white p-6 shadow-sm md:p-8 lg:grid-cols-[0.85fr_1.15fr]">
        <div class="space-y-4">
          <span class="inline-flex items-center gap-2 rounded-full bg-avocado-50 px-4 py-2 text-xs font-bold uppercase tracking-[0.18em] text-avocado-700">
            <Send class="h-4 w-4" />
            Gửi yêu cầu
          </span>
          <h2 class="text-3xl font-black leading-tight text-avocado-950">ALOO sẽ liên hệ lại với bạn</h2>
          <p class="text-sm leading-relaxed text-slate-600">
            Điền thông tin bên dưới nếu bạn cần tư vấn nhanh về nhượng quyền, mặt bằng, menu hoặc hợp tác truyền thông.
          </p>
          <div class="rounded-2xl bg-avocado-50 p-5 text-sm leading-relaxed text-avocado-900">
            Dữ liệu form được lưu vào contact messages để đội ngũ vận hành xử lý trong CMS/API thật.
          </div>
        </div>

        <form class="grid gap-4" data-testid="contact-form" novalidate @submit.prevent="submitContact">
          <div class="grid gap-4 sm:grid-cols-2">
            <label class="grid gap-2 text-sm font-bold text-avocado-950">
              Họ tên
              <input
                v-model="form.fullName"
                class="h-12 rounded-xl border border-avocado-100 bg-white px-4 text-sm font-semibold outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                :class="{ 'border-red-300 focus:border-red-400 focus:ring-red-100': errors.fullName }"
                name="fullName"
                placeholder="Nguyễn Văn A"
                required
                type="text"
              />
              <span v-if="errors.fullName" class="text-xs font-semibold text-red-600">{{ errors.fullName }}</span>
            </label>

            <label class="grid gap-2 text-sm font-bold text-avocado-950">
              Số điện thoại
              <input
                v-model="form.phone"
                class="h-12 rounded-xl border border-avocado-100 bg-white px-4 text-sm font-semibold outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                :class="{ 'border-red-300 focus:border-red-400 focus:ring-red-100': errors.phone }"
                name="phone"
                pattern="^[0-9+() .-]{8,40}$"
                placeholder="0900 888 168"
                required
                type="tel"
              />
              <span v-if="errors.phone" class="text-xs font-semibold text-red-600">{{ errors.phone }}</span>
            </label>
          </div>

          <div class="grid gap-4 sm:grid-cols-2">
            <label class="grid gap-2 text-sm font-bold text-avocado-950">
              Email
              <input
                v-model="form.email"
                class="h-12 rounded-xl border border-avocado-100 bg-white px-4 text-sm font-semibold outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                :class="{ 'border-red-300 focus:border-red-400 focus:ring-red-100': errors.email }"
                name="email"
                placeholder="email@example.com"
                type="email"
              />
              <span v-if="errors.email" class="text-xs font-semibold text-red-600">{{ errors.email }}</span>
            </label>

            <label class="grid gap-2 text-sm font-bold text-avocado-950">
              Khu vực
              <input
                v-model="form.province"
                class="h-12 rounded-xl border border-avocado-100 bg-white px-4 text-sm font-semibold outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                name="province"
                placeholder="TP.HCM, Đà Nẵng..."
                type="text"
              />
            </label>
          </div>

          <label class="grid gap-2 text-sm font-bold text-avocado-950">
            Nội dung cần hỗ trợ
            <textarea
              v-model="form.message"
              class="min-h-32 rounded-xl border border-avocado-100 bg-white px-4 py-3 text-sm font-semibold outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
              :class="{ 'border-red-300 focus:border-red-400 focus:ring-red-100': errors.message }"
              name="message"
              placeholder="Tôi muốn được tư vấn mô hình ALOO phù hợp..."
              required
            ></textarea>
            <span v-if="errors.message" class="text-xs font-semibold text-red-600">{{ errors.message }}</span>
          </label>

          <button
            class="inline-flex h-12 items-center justify-center gap-2 rounded-full bg-avocado-900 px-6 text-sm font-black uppercase tracking-wider text-white transition hover:bg-avocado-800 disabled:cursor-not-allowed disabled:opacity-60"
            :disabled="isSubmitting"
            type="submit"
          >
            <Send class="h-4 w-4" />
            {{ isSubmitting ? 'Đang gửi...' : 'Gửi liên hệ' }}
          </button>
        </form>
      </div>

      <!-- Quick Franchise CTA -->
      <div class="mt-20 overflow-hidden rounded-[2.5rem] bg-gradient-to-br from-avocado-950 via-avocado-900 to-[#122310] p-8 sm:p-12 text-white relative shadow-xl">
        <div class="absolute -right-20 -top-20 w-80 h-80 bg-cream-400/5 rounded-full blur-3xl pointer-events-none"></div>
        <div class="grid gap-6 lg:grid-cols-[1fr_auto] lg:items-center relative z-10">
          <div class="space-y-3">
            <span class="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-[0.2em] text-cream-300">
              <Sparkles class="h-3.5 w-3.5 fill-cream-300" />
              Đăng ký tư vấn trực tiếp
            </span>
            <h2 class="text-2xl sm:text-3xl font-black">Nhận tư vấn nhượng quyền chi tiết qua Zalo/Điện thoại</h2>
            <p class="max-w-2xl text-sm leading-relaxed text-avocado-100/90">
              Đội ngũ phụ trách dự án F&B của ALOO sẽ gửi thông tin hồ sơ nhượng quyền & khảo sát địa điểm chi tiết cho bạn.
            </p>
          </div>
          <RouterLink
            to="/consultation"
            class="rounded-full bg-cream-400 px-8 py-4 text-center font-bold text-avocado-950 hover:bg-cream-300 transition duration-300 shadow-lg shadow-cream-400/20 text-xs uppercase tracking-wider"
          >
            Đăng ký tư vấn miễn phí
          </RouterLink>
        </div>
      </div>
    </section>
  </main>
</template>



