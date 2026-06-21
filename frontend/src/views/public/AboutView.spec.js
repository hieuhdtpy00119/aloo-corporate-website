import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import AboutView from './AboutView.vue'
import { useAppStore } from '../../stores/appStore'

const translations = {
  'about.heroEyebrow': 'Câu chuyện thương hiệu',
  'about.heroTitleLine1': 'Hành trình nâng tầm',
  'about.heroTitleHighlight': 'trái bơ Việt',
  'about.heroDescription': 'Từ một hộ kinh doanh nhỏ năm 2013',
  'about.heroTagline': 'Năng lượng xanh, mát vị lành',
  'about.metricsProducts': 'Sản phẩm đang bán',
  'about.metricsLocations': 'Cửa hàng hoạt động',
  'about.metricsPosts': 'Bài viết thương hiệu',
  'about.metricsErrorHint': 'Không tải được số liệu từ hệ thống.',
  'about.section1Title': 'Nâng tầm giá trị trái bơ Việt Nam',
  'about.section1Caption': 'Khởi nghiệp từ năm 2013 · Bứt phá từ 2023',
  'about.section1Eyebrow': 'Khởi nguồn từ khát vọng',
  'about.section1P1': 'Câu chuyện của Aloo Kem Bơ bắt đầu từ năm 2013',
  'about.section1P2': 'Đến năm 2023, dưới sự dẫn dắt của CEO',
  'about.section2Eyebrow': 'Vượt qua thách thức',
  'about.section2Title': 'Bằng sự chân thực và tử tế',
  'about.section2Subtitle': 'Từ vùng trồng đến tay thực khách',
  'about.section2P1': 'Khó khăn lớn nhất là đảm bảo nguồn bơ tươi ổn định.',
  'about.section2P2': 'Chính sự nghiêm túc và kiên định',
  'about.qualityTitle': '🌱 Cam kết chất lượng Aloo',
  'about.section2ImageCaption': 'Bơ tươi thật · Xanh · Lành · Ngon',
  'about.section3Eyebrow': 'Hệ sinh thái & Tầm nhìn',
  'about.section3Title': 'Vươn mình ra biển lớn',
  'about.section3P1': 'Tính đến năm 2026, Aloo Kem Bơ sở hữu hệ thống chuỗi cửa hàng',
  'about.section3MenuLabel': 'Menu đặc sắc',
  'about.section3AudienceTitle': 'Phục vụ đa dạng đối tượng',
  'about.section3AudienceText': 'Học sinh · Sinh viên · Gia đình · Khách du lịch',
  'about.section3VisionLabel': 'Tầm nhìn 2030',
  'about.section3VisionTitle': '~50 cửa hàng trên toàn quốc',
  'about.section3VisionDesc': 'Chuỗi kem bơ tiên phong · Lan tỏa năng lượng xanh',
  'about.section3ImageCaptionLeft': 'Quy Nhơn & Nha Trang',
  'about.section3ImageCaptionRight': 'Mục tiêu 50 CH · 2030',
  'about.valuesEyebrow': '5 giá trị cốt lõi',
  'about.valuesTitle': 'Nền tảng vững chắc của Aloo',
  'about.valuesDesc': 'Mỗi ly kem bơ Aloo đều mang theo 5 giá trị',
  'about.timelineEyebrow': 'Lộ trình phát triển',
  'about.timelineTitle': 'Từ công thức chủ lực đến mô hình hệ thống',
  'about.timelineErrorHint': 'Không tải được lộ trình từ CMS.',
  'about.timelineLoadError': 'Không tải được lộ trình thương hiệu',
  'about.ctaConclusionEyebrow': 'Kết luận',
  'about.ctaConclusionTitle': 'Hơn một thập kỷ đi lên từ',
  'about.ctaConclusionHighlight': 'chất lượng thật & giá trị thật',
  'about.ctaConclusionBody': 'Không chỉ là món giải nhiệt ngon miệng',
  'about.ctaVisitStore': 'Ghé cửa hàng ngay',
  'about.ctaViewMenu': 'Xem menu kem bơ',
  'about.ctaFootnote': 'Cửa hàng tại Quy Nhơn & Nha Trang · Giá từ 20.000đ',
  'about.quickMenuEyebrow': 'Menu',
  'about.quickMenuTitle': 'Khám phá sản phẩm ALOO',
  'about.quickMenuDescription': 'Kem bơ, bơ xoài, bơ sầu riêng',
  'about.quickMenuLink': 'Xem menu',
  'about.quickFranchiseEyebrow': 'Nhượng quyền',
  'about.quickFranchiseTitle': 'Cùng Aloo vươn xa',
  'about.quickFranchiseDescription': 'Cơ hội gia nhập hệ thống 50 cửa hàng',
  'about.quickFranchiseLink': 'Tìm hiểu ngay',
}

const translationArrays = {
  'about.coreValues': [
    { label: 'Tôn trọng', desc: 'Trân trọng mọi thành viên.' },
    { label: 'Yêu thương', desc: 'Gắn kết cộng đồng.' },
  ],
  'about.defaultTimeline': [
    { year: '2013', title: 'Khởi nguồn ý tưởng', desc: 'Mong muốn tạo sản phẩm từ bơ tươi.' },
    { year: '2015', title: 'Hoàn thiện công thức', desc: 'Tinh chỉnh hương vị.' },
  ],
  'about.menuItems': [
    { name: 'Kem Bơ Truyền Thống', tag: 'Signature', color: '#007A35' },
  ],
  'about.section1Milestones': [
    '2013 · Khởi nguồn ý tưởng',
    '2015 · Hoàn thiện công thức',
  ],
  'about.qualityPoints': [
    'Kiểm soát vùng trồng nghiêm ngặt',
    'Quy trình sơ chế & bảo quản chuẩn hoá',
  ],
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
    tm: (key) => translationArrays[key] || [],
  }),
}))

vi.mock('../../services/seoService', () => ({
  routeSeo: {
    '/about': {
      title: 'Về ALOO',
      description: 'About ALOO',
    },
  },
  setSeoMeta: vi.fn(),
}))

vi.mock('../../services/cmsService', () => ({
  brandTimelineService: {
    list: vi.fn().mockResolvedValue({ data: [] }),
  },
}))

describe('AboutView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  const mountView = () => {
    const store = useAppStore()
    vi.spyOn(store, 'fetchProducts').mockResolvedValue()
    vi.spyOn(store, 'fetchLocations').mockResolvedValue()
    vi.spyOn(store, 'fetchCategories').mockResolvedValue()
    vi.spyOn(store, 'fetchPosts').mockResolvedValue()

    return mount(AboutView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })
  }

  it('renders the hero title from i18n', () => {
    const wrapper = mountView()

    expect(wrapper.text()).toContain('Hành trình nâng tầm')
    expect(wrapper.text()).toContain('trái bơ Việt')
  })

  it('shows metric skeleton placeholders while page data is loading', () => {
    const store = useAppStore()
    store.loading.products = true
    store.loading.locations = true
    store.loading.posts = true

    const wrapper = mountView()

    const skeletons = wrapper.findAll('.animate-pulse')
    expect(skeletons.length).toBeGreaterThanOrEqual(3)
  })
})
