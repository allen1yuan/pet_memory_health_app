// ============================================================
// 宠忆时光 - 图标字形集中表（emoji 字形，零资源依赖）
// entry/src/main/ets/common/Icons.ets
//
// 说明：MVP 阶段统一用 emoji 字形渲染（Text 承载），后续可整体
// 替换为 SymbolGlyph(sys.symbol.*) 或 PNG，调用点不变。
// ============================================================

export class Icons {
  // 底部导航
  static readonly home: string = '🏠'
  static readonly album: string = '🖼️'
  static readonly health: string = '🩺'
  static readonly mine: string = '👤'

  // 通用
  static readonly bell: string = '🔔'
  static readonly plus: string = '＋'
  static readonly back: string = '‹'
  static readonly chevronRight: string = '›'
  static readonly chevronDown: string = '⌄'
  static readonly search: string = '🔍'
  static readonly share: string = '↗'
  static readonly copy: string = '⧉'
  static readonly edit: string = '✎'
  static readonly check: string = '✓'
  static readonly camera: string = '📷'
  static readonly photoPlus: string = '🖼️'
  static readonly calendar: string = '📅'
  static readonly mapPin: string = '📍'
  static readonly hospital: string = '🏥'
  static readonly shieldCheck: string = '🛡'
  static readonly star: string = '★'
  static readonly starHollow: string = '☆'
  static readonly crown: string = '👑'
  static readonly gift: string = '🎁'
  static readonly settings: string = '⚙'
  static readonly lock: string = '🔒'
  static readonly help: string = '❓'
  static readonly logout: string = '⎋'
  static readonly weight: string = '⚖'
  static readonly flag: string = '🚩'

  // 宠物 / 里程碑 / 健康类型
  static readonly dog: string = '🐕'
  static readonly cat: string = '🐈'
  static readonly paw: string = '🐾'
  static readonly cake: string = '🎂'
  static readonly vaccine: string = '💉'
  static readonly trip: string = '🏖️'
  static readonly checkup: string = '🩺'
  static readonly stethoscope: string = '🩺'
  static readonly bug: string = '🐛'
  static readonly alert: string = '⚠'
  static readonly food: string = '🍖'
  static readonly phone: string = '📱'
  static readonly huawei: string = '⊞'
}
