// ============================================================
// 宠忆时光 HarmonyOS - 常量定义（暖琥珀 · 深色底）
// entry/src/main/ets/common/Constants.ets
//
// 设计准则：
//   - 主色暖橘 #F28A3D，辅色陶土 #D96C4A
//   - 健康状态语义色：逾期红 / 临近琥珀 / 正常绿
//   - 颜色统一通过 Theme.color.* 引用，禁止页面硬编码
// ============================================================

export class AppConstants {
  // ── Preferences（本地 KV）──
  static readonly PREF_NAME: string = 'chongyi_prefs'
  static readonly KEY_SESSION_ACTIVE: string = 'session_active'
  static readonly KEY_ONBOARDING_DONE: string = 'onboarding_done'
  static readonly KEY_CURRENT_PET_ID: string = 'current_pet_id'
  static readonly KEY_PHONE: string = 'login_phone'
  static readonly KEY_NOTIFY_ENABLED: string = 'notify_enabled'
  static readonly KEY_PLAN_NAME: string = 'plan_name'
  static readonly KEY_USER_NAME: string = 'user_name'

  // ── RDB（结构化数据）──
  static readonly DB_NAME: string = 'chongyi.db'

  // ── 路由页面 ──
  static readonly PAGE_LOGIN: string = 'pages/LoginPage'
  static readonly PAGE_PET_SETUP: string = 'pages/PetSetupPage'
  static readonly PAGE_MAIN: string = 'pages/MainPage'
  static readonly PAGE_TIMELINE: string = 'pages/TimelinePage'
  static readonly PAGE_HOSPITAL: string = 'pages/HospitalPage'
  static readonly PAGE_HOSPITAL_DETAIL: string = 'pages/HospitalDetailPage'
  static readonly PAGE_PLANS: string = 'pages/PlansPage'

  // ── 字号 ──
  static readonly FONT_SIZE_TITLE: number = 24
  static readonly FONT_SIZE_SUBTITLE: number = 18
  static readonly FONT_SIZE_BODY: number = 16
  static readonly FONT_SIZE_CAPTION: number = 14
  static readonly FONT_SIZE_SMALL: number = 12

  // ── 圆角 ──
  static readonly RADIUS_SMALL: number = 6
  static readonly RADIUS_MEDIUM: number = 12
  static readonly RADIUS_LARGE: number = 16
  static readonly RADIUS_ROUND: number = 999

  // ── 间距 ──
  static readonly SPACE_XS: number = 4
  static readonly SPACE_SM: number = 8
  static readonly SPACE_MD: number = 16
  static readonly SPACE_LG: number = 24
  static readonly SPACE_XL: number = 32

  // ── 业务常量 ──
  static readonly REMINDER_SOON_DAYS: number = 7   // 距到期 7 天内视为"临近"
  static readonly DAY_MS: number = 86400000
}
