// ============================================================
// 宠忆时光 - 数据模型
// entry/src/main/ets/model/PetModels.ets
//
// ArkTS 不允许无类型对象字面量，所有结构以 class 定义并给默认值。
// ============================================================

// ── 宠物 ──
export class Pet {
  id: number = 0
  name: string = ''
  species: string = 'dog'        // 'dog' | 'cat' | 'other'
  breed: string = ''
  birthday: number = 0           // 毫秒时间戳
  gender: string = 'male'        // 'male' | 'female'
  weightKg: number = 0
  avatarUri: string = ''         // 沙箱内图片路径，空则用占位
  createdAt: number = 0
}

// ── 成长里程碑 ──
export class Milestone {
  id: number = 0
  petId: number = 0
  type: string = 'custom'        // 'birthday'|'vaccine'|'trip'|'checkup'|'custom'
  title: string = ''
  date: number = 0
  note: string = ''
  photoUris: string[] = []       // 入库时 JSON 序列化为字符串
}

// ── 相册照片 ──
export class PhotoItem {
  id: number = 0
  petId: number = 0
  uri: string = ''               // 沙箱内路径
  category: string = 'daily'     // 'daily'|'outdoor'|'hospital'|'food'|'other'
  takenAt: number = 0
}

// ── 健康提醒 ──
export class HealthReminder {
  id: number = 0
  petId: number = 0
  type: string = 'vaccine'       // 'vaccine'|'deworm'|'checkup'|'weight'|'other'
  title: string = ''
  dueDate: number = 0
  cycleMonths: number = 0
  done: boolean = false
  notify: boolean = true
  // 读取时计算：'overdue' | 'soon' | 'ok'
  status: string = 'ok'
}

// ── 体重记录 ──
export class WeightEntry {
  id: number = 0
  petId: number = 0
  weightKg: number = 0
  recordedAt: number = 0
}

// ── 医院评价（只读）──
export class Review {
  author: string = ''
  rating: number = 5
  content: string = ''
}

// ── 宠医星认证医院（只读，来自 rawfile JSON）──
export class Hospital {
  id: string = ''
  name: string = ''
  star: number = 3               // 1..3
  address: string = ''
  distanceText: string = ''
  services: string[] = []
  certLevel: string = ''
  certValidUntil: string = ''
  certMethod: string = '第三方中立 · 无商业赞助'
  reviews: Review[] = []
}

// ── 会员方案（静态，只读预览）──
export class PlanItem {
  name: string = ''
  price: string = ''
  desc: string = ''
  current: boolean = false
  recommended: boolean = false
}

// ── 分类标签元信息（UI 用）──
export class CategoryMeta {
  key: string = ''
  label: string = ''
}
