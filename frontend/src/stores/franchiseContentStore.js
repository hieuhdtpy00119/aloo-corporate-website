import { defineStore } from 'pinia'
import { franchiseContentService } from '../services/cmsService'

const franchiseContent = {
  hero: [
    {
      id: 1,
      subtitle: 'Nhượng quyền Aloo Kem Bơ',
      title: 'Cùng Aloo kinh doanh kem bơ — Mô hình dễ vận hành, giàu tiềm năng',
      description:
        'Hơn 10 năm xây dựng thương hiệu từ trái bơ Việt, Aloo Kem Bơ đồng hành cùng đối tác từ khảo sát mặt bằng, setup cửa hàng, đào tạo vận hành đến khai trương thực tế. Tầm nhìn 2030: ~50 cửa hàng lan tỏa Năng lượng xanh, mát vị lành.',
      image: '/about/aloo-franchise-hero.png',
      buttonText: 'Nhận tư vấn miễn phí',
      buttonLink: '/consultation',
      secondaryButtonText: 'Xem chi phí đầu tư',
      secondaryButtonLink: '#investment',
      status: 'ACTIVE',
    },
  ],
  advantages: [
    {
      id: 1,
      icon: 'brand',
      title: 'Thương hiệu 10+ năm uy tín',
      description:
        'Thành lập từ 2013, CEO Nguyễn Thị Hoàng Phương dẫn dắt từ 2023. Aloo là thương hiệu kem bơ có lịch sử phát triển bài bản, được cộng đồng Quy Nhơn và Nha Trang tin yêu.',
      status: 'ACTIVE',
    },
    {
      id: 2,
      icon: 'product',
      title: 'Sản phẩm "siêu thực phẩm" độc đáo',
      description:
        'Bơ là siêu thực phẩm giàu dinh dưỡng, khác biệt hoàn toàn với kem truyền thống. Menu đa dạng: kem bơ, bơ xoài, bơ sầu riêng, bơ mãng cầu, bơ Aloo đặc biệt — từ 20.000đ.',
      status: 'ACTIVE',
    },
    {
      id: 3,
      icon: 'operation',
      title: 'Vận hành tinh gọn, dễ đào tạo',
      description:
        'Menu tập trung, định lượng chuẩn hóa, quy trình sơ chế bơ tươi được kiểm soát chặt. Đào tạo nhân sự nhanh, không yêu cầu kinh nghiệm F&B trước.',
      status: 'ACTIVE',
    },
    {
      id: 4,
      icon: 'cost',
      title: 'Đa mô hình — Linh hoạt vốn đầu tư',
      description:
        'Từ AlooBike (xe bán dạo linh hoạt) đến Kiosk, Standard và Flagship — đa dạng gói đầu tư phù hợp ngân sách và mặt bằng từng khu vực, giá từ 50 triệu đồng.',
      status: 'ACTIVE',
    },
    {
      id: 5,
      icon: 'support',
      title: 'Hỗ trợ toàn diện từ A–Z',
      description:
        'Đồng hành khảo sát mặt bằng, thiết kế bảng hiệu, setup thiết bị, đào tạo nhân viên, checklist khai trương và theo dõi vận hành sau mở bán.',
      status: 'ACTIVE',
    },
    {
      id: 6,
      icon: 'marketing',
      title: 'Marketing & Truyền thông bài bản',
      description:
        'Cung cấp bộ nhận diện cửa hàng, nội dung mạng xã hội, tài liệu khai trương và định hướng chiến dịch marketing cho từng điểm bán địa phương.',
      status: 'ACTIVE',
    },
  ],
  models: [
    {
      id: 1,
      modelName: 'AlooBike',
      area: 'Không cần mặt bằng cố định',
      investment: '50–80 triệu',
      description:
        'Xe đẩy / xe máy bán kem bơ linh hoạt, cơ động. Phù hợp sự kiện, hội chợ, bãi biển, khu vui chơi và các điểm đông người. Đầu tư thấp nhất, dễ triển khai nhanh.',
      image: '/about/aloo-kiosk.png',
      featured: false,
      status: 'ACTIVE',
    },
    {
      id: 2,
      modelName: 'Kiosk',
      area: '10–20 m²',
      investment: '120–200 triệu',
      description:
        'Mặt bằng nhỏ gọn, ưu tiên bán mang đi. Phù hợp khu dân cư, gần trường học, chợ hoặc vị trí có lưu lượng khách đi lại cao.',
      image: '/about/aloo-kiosk.png',
      featured: false,
      status: 'ACTIVE',
    },
    {
      id: 3,
      modelName: 'Standard',
      area: '20–50 m²',
      investment: '280–450 triệu',
      description:
        'Mô hình cân bằng giữa trải nghiệm tại chỗ và vận hành tinh gọn. Phù hợp phố thương mại, khu du lịch ven biển như Quy Nhơn, Nha Trang.',
      image: '/about/aloo-standard.png',
      featured: true,
      status: 'ACTIVE',
    },
    {
      id: 4,
      modelName: 'Flagship',
      area: '50 m²+',
      investment: '500–750 triệu',
      description:
        'Không gian nhận diện nổi bật, trải nghiệm đỉnh cao. Phù hợp khu trung tâm, phố du lịch, vị trí chiến lược với lưu lượng khách cao.',
      image: '/about/aloo-standard.png',
      featured: false,
      status: 'ACTIVE',
    },
  ],
  investment: [
    {
      id: 1,
      itemName: 'Phí nhượng quyền & thương hiệu',
      kioskValue: 'Theo gói',
      standardValue: 'Theo gói',
      flagshipValue: 'Theo gói',
      note: 'Bao gồm bản quyền thương hiệu, bộ nhận diện, tài liệu vận hành và quy trình.',
      status: 'ACTIVE',
    },
    {
      id: 2,
      itemName: 'Thiết bị & quầy pha chế bơ',
      kioskValue: '40–70 triệu',
      standardValue: '100–180 triệu',
      flagshipValue: '200–320 triệu',
      note: 'Máy xay, tủ lạnh, thiết bị bảo quản bơ tươi, quầy pha chế theo tiêu chuẩn Aloo.',
      status: 'ACTIVE',
    },
    {
      id: 3,
      itemName: 'Bảng hiệu, nội thất & trang trí',
      kioskValue: '25–45 triệu',
      standardValue: '80–140 triệu',
      flagshipValue: '160–250 triệu',
      note: 'Thiết kế theo bộ nhận diện Aloo (xanh bơ – kem vàng), tùy diện tích mặt tiền.',
      status: 'ACTIVE',
    },
    {
      id: 4,
      itemName: 'Nguyên liệu khai trương',
      kioskValue: '10–20 triệu',
      standardValue: '25–45 triệu',
      flagshipValue: '45–70 triệu',
      note: 'Bơ tươi, nguyên liệu topping và nguyên vật liệu ban đầu để vận hành.',
      status: 'ACTIVE',
    },
    {
      id: 5,
      itemName: 'Đào tạo & hỗ trợ khai trương',
      kioskValue: 'Included',
      standardValue: 'Included',
      flagshipValue: 'Included',
      note: 'Đào tạo tại Quy Nhơn hoặc tại điểm bán, bao gồm lý thuyết và thực hành.',
      status: 'ACTIVE',
    },
  ],
  costs: [
    {
      id: 1,
      title: 'AlooBike',
      amount: '50–80 triệu',
      note: 'Xe cơ động, không cần mặt bằng cố định. Lý tưởng để thử nghiệm thị trường.',
      status: 'ACTIVE',
    },
    {
      id: 2,
      title: 'Kiosk',
      amount: '120–200 triệu',
      note: 'Mặt bằng 10–20m², khu dân cư, gần trường học hoặc chợ.',
      status: 'ACTIVE',
    },
    {
      id: 3,
      title: 'Standard',
      amount: '280–450 triệu',
      note: 'Mặt bằng 20–50m², phố thương mại, khu du lịch biển.',
      status: 'ACTIVE',
    },
    {
      id: 4,
      title: 'Flagship',
      amount: '500–750 triệu',
      note: 'Mặt bằng 50m²+, trung tâm thành phố, điểm du lịch chiến lược.',
      status: 'ACTIVE',
    },
  ],
  profit: [
    {
      id: 1,
      metric: 'Khách/ngày',
      value: '80–200',
      description: 'Với vị trí có lưu lượng ổn định tại thành phố du lịch Quy Nhơn hoặc Nha Trang.',
      status: 'ACTIVE',
    },
    {
      id: 2,
      metric: 'Giá bán trung bình',
      value: '20k–65k',
      description: 'Giá từ 20.000đ cho kem bơ cơ bản, lên đến 65.000đ cho các vị đặc biệt và combo.',
      status: 'ACTIVE',
    },
    {
      id: 3,
      metric: 'Doanh thu tham khảo',
      value: '80–300 triệu/tháng',
      description: 'Tùy mô hình, mặt bằng và mùa du lịch. Không phải cam kết lợi nhuận.',
      status: 'ACTIVE',
    },
  ],
  process: [
    {
      id: 1,
      stepNumber: 1,
      title: 'Đăng ký tư vấn',
      description: 'Điền thông tin khu vực, ngân sách và mục tiêu kinh doanh để đội Aloo liên hệ.',
      status: 'ACTIVE',
    },
    {
      id: 2,
      stepNumber: 2,
      title: 'Tư vấn & chọn mô hình',
      description: 'Aloo đề xuất mô hình phù hợp: AlooBike, Kiosk, Standard hay Flagship theo ngân sách và vị trí.',
      status: 'ACTIVE',
    },
    {
      id: 3,
      stepNumber: 3,
      title: 'Khảo sát mặt bằng',
      description: 'Đánh giá vị trí thực địa: lưu lượng khách, đối thủ cạnh tranh, khả năng setup.',
      status: 'ACTIVE',
    },
    {
      id: 4,
      stepNumber: 4,
      title: 'Ký hợp đồng nhượng quyền',
      description: 'Thống nhất phạm vi hỗ trợ, timeline triển khai, tiêu chuẩn vận hành và điều khoản hợp tác.',
      status: 'ACTIVE',
    },
    {
      id: 5,
      stepNumber: 5,
      title: 'Setup & Đào tạo',
      description: 'Triển khai nhận diện thương hiệu, lắp đặt thiết bị, đào tạo pha chế và quản lý vận hành.',
      status: 'ACTIVE',
    },
    {
      id: 6,
      stepNumber: 6,
      title: 'Khai trương & Hậu mãi',
      description: 'Hỗ trợ checklist khai trương, truyền thông khai trương và theo dõi vận hành 30 ngày đầu.',
      status: 'ACTIVE',
    },
  ],
  founder_story: [
    {
      id: 1,
      founderName: 'CEO Nguyễn Thị Hoàng Phương — Công ty TNHH Aloo Quy Nhơn',
      image: '/about/aloo-origin-story.png',
      title: 'Từ hộ kinh doanh nhỏ đến thương hiệu kem bơ tiên phong',
      storyContent:
        'Aloo Kem Bơ khởi nguồn từ 2013 với khát vọng nâng tầm giá trị trái bơ Việt Nam — một siêu thực phẩm chưa được khai thác đúng tiềm năng. Sau hơn 10 năm kiên trì, đến 2023, dưới sự dẫn dắt bài bản của CEO Nguyễn Thị Hoàng Phương, Aloo bắt đầu giai đoạn bứt phá mạnh mẽ.\n\nChúng tôi tin rằng chìa khóa thành công không phải là chạy theo xu hướng, mà là giữ vững cam kết "bơ tươi thật" — từ vùng trồng đến tay thực khách. Chính sự chân thực và tử tế đó đã xây dựng niềm tin bền vững trong cộng đồng.\n\nNhượng quyền Aloo không chỉ là mở một cửa hàng — đó là tham gia vào hành trình lan tỏa "Năng lượng xanh, mát vị lành" tới cộng đồng Việt Nam.',
      status: 'ACTIVE',
    },
  ],
  faq: [
    {
      id: 1,
      question: 'Aloo có bao nhiêu mô hình nhượng quyền?',
      answer:
        'Aloo có 4 mô hình: AlooBike (xe cơ động, 50–80 triệu), Kiosk (10–20m², 120–200 triệu), Standard (20–50m², 280–450 triệu) và Flagship (50m²+, 500–750 triệu). Đội ngũ tư vấn sẽ giúp bạn chọn mô hình phù hợp nhất với ngân sách và vị trí.',
      status: 'ACTIVE',
    },
    {
      id: 2,
      question: 'Tôi cần kinh nghiệm F&B không?',
      answer:
        'Không bắt buộc. Aloo cung cấp chương trình đào tạo bài bản từ A-Z: quy trình chọn và sơ chế bơ tươi, công thức pha chế chuẩn, kỹ năng bán hàng và quản lý vận hành cơ bản trước khai trương.',
      status: 'ACTIVE',
    },
    {
      id: 3,
      question: 'Nguồn bơ tươi lấy từ đâu?',
      answer:
        'Aloo kiểm soát chặt chuỗi cung ứng từ các vùng trồng bơ uy tín trong nước (Đắk Lắk, Lâm Đồng...). Đối tác nhượng quyền được hướng dẫn nguồn nguyên liệu và tiêu chuẩn kiểm tra chất lượng bơ đầu vào.',
      status: 'ACTIVE',
    },
    {
      id: 4,
      question: 'Mất bao lâu để mở cửa hàng?',
      answer:
        'Thông thường 30–60 ngày từ khi ký hợp đồng đến khai trương, tùy quy mô mô hình và tình trạng mặt bằng. AlooBike có thể triển khai nhanh hơn trong 15–30 ngày.',
      status: 'ACTIVE',
    },
    {
      id: 5,
      question: 'Aloo hỗ trợ marketing cho đối tác không?',
      answer:
        'Có. Đối tác nhận bộ nhận diện thương hiệu đầy đủ, nội dung khai trương cho mạng xã hội, checklist truyền thông và định hướng chiến dịch marketing địa phương.',
      status: 'ACTIVE',
    },
    {
      id: 6,
      question: 'Doanh thu có được đảm bảo không?',
      answer:
        'Aloo không cam kết doanh thu cụ thể vì kết quả phụ thuộc vào vị trí mặt bằng, chất lượng vận hành và thị trường địa phương. Tuy nhiên, các cửa hàng tại Quy Nhơn và Nha Trang tham khảo đạt 80–300 triệu/tháng.',
      status: 'ACTIVE',
    },
    {
      id: 7,
      question: 'Có hỗ trợ sau khai trương không?',
      answer:
        'Có. Aloo theo dõi vận hành trong 30 ngày đầu sau khai trương, hỗ trợ xử lý vấn đề phát sinh, tư vấn tối ưu menu và đội ngũ, đảm bảo cửa hàng hoạt động ổn định.',
      status: 'ACTIVE',
    },
  ],
  cta: [
    {
      id: 1,
      title: 'Sẵn sàng mở cửa hàng Aloo?',
      description:
        'Đăng ký tư vấn để đội ngũ Aloo phân tích khu vực, đề xuất mô hình phù hợp và dự toán chi phí đầu tư chi tiết cho bạn.',
      buttonText: 'Nhận tư vấn miễn phí',
      buttonLink: '/consultation',
      status: 'ACTIVE',
    },
  ],
  benefits: [],
  conditions: [],
}

const cloneContent = () =>
  Object.fromEntries(Object.entries(franchiseContent).map(([key, items]) => [key, items.map((item) => ({ ...item }))]))

const emptyContent = () => Object.fromEntries(Object.keys(franchiseContent).map((key) => [key, []]))

const parseContentPayload = (item) => {
  if (!item.content) return {}
  try {
    return JSON.parse(item.content)
  } catch {
    return { description: item.content }
  }
}

const normalizeFranchiseContent = (item) => ({
  id: item.id,
  sectionKey: item.sectionKey,
  title: item.title,
  amount: item.amount,
  note: item.note,
  sortOrder: Number(item.sortOrder || 0),
  status: item.status || 'ACTIVE',
  ...parseContentPayload(item),
})

const groupContentBySection = (items) => {
  const grouped = emptyContent()
  items
    .map(normalizeFranchiseContent)
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .forEach((item) => {
      const section = item.sectionKey || 'benefits'
      if (!grouped[section]) grouped[section] = []
      grouped[section].push(item)
    })
  return grouped
}

const isVisible = (item) => !['HIDDEN', 'INACTIVE'].includes(item.status)

export const useFranchiseContentStore = defineStore('franchiseContent', {
  state: () => ({
    content: cloneContent(),
    loading: false,
    error: '',
  }),
  getters: {
    visibleBenefits: (state) => (state.content.benefits || []).filter(isVisible),
    visibleHero: (state) => (state.content.hero || []).filter(isVisible),
    visibleAdvantages: (state) => (state.content.advantages || []).filter(isVisible),
    visibleModels: (state) => (state.content.models || []).filter(isVisible),
    visibleInvestment: (state) => (state.content.investment || []).filter(isVisible),
    visibleProfit: (state) => (state.content.profit || []).filter(isVisible),
    visibleConditions: (state) => (state.content.conditions || []).filter(isVisible),
    visibleProcess: (state) => (state.content.process || []).filter(isVisible),
    visibleFounderStory: (state) => (state.content.founder_story || []).filter(isVisible),
    visibleFaq: (state) => (state.content.faq || []).filter(isVisible),
    visibleCta: (state) => (state.content.cta || []).filter(isVisible),
    visibleCosts: (state) => (state.content.costs || []).filter(isVisible),
  },
  actions: {
    async fetchContent() {
      this.loading = true
      this.error = ''
      try {
        const { data } = await franchiseContentService.list()
        const parsed = groupContentBySection(Array.isArray(data) ? data : [])
        // Only override sections that have actual CMS data; keep fallback for empty sections
        const merged = cloneContent()
        Object.keys(parsed).forEach((key) => {
          if (parsed[key] && parsed[key].length > 0) {
            merged[key] = parsed[key]
          }
        })
        this.content = merged
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Không tải được nội dung nhượng quyền'
        this.content = cloneContent()
        throw error
      } finally {
        this.loading = false
      }
    },
  },
})
