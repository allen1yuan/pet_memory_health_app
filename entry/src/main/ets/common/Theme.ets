// ============================================================
// 宠忆时光 HarmonyOS - 设计 Token 统一入口（暖琥珀）
// entry/src/main/ets/common/Theme.ets
//
// 约束：
//   1. 颜色必须通过 Theme.color.* 引用，禁止页面硬编码颜色字符串
//   2. 颜色底层走 $r('app.color.*')，light/dark 自动生效
//   3. 圆角 / 间距 / 字号 / 阴影 / 动效锁死在此文件
//   字段名沿用播客工程，保证复用组件零改动编译通过
// ============================================================

export class ThemeColor {
  // ── 品牌主色（琥珀）──
  static readonly primary:         Resource = $r('app.color.brand_primary')
  static readonly primaryLight:    Resource = $r('app.color.brand_primary_light')
  static readonly primaryDeep:     Resource = $r('app.color.brand_primary_deep')
  static readonly primaryGradEnd:  Resource = $r('app.color.brand_primary_grad_end')
  static readonly primaryPressed:  Resource = $r('app.color.brand_primary_pressed')
  static readonly primaryDim:      Resource = $r('app.color.brand_primary_dim')
  static readonly accent:          Resource = $r('app.color.brand_accent')
  static readonly accentDim:       Resource = $r('app.color.brand_accent_dim')
  static readonly highlight:       Resource = $r('app.color.brand_highlight')

  // ── 行动色（同琥珀主色）──
  static readonly ctaAmber:        Resource = $r('app.color.cta_amber')
  static readonly ctaAmberPressed: Resource = $r('app.color.cta_amber_pressed')
  static readonly ctaAmberDim:     Resource = $r('app.color.cta_amber_dim')

  // ── 背景层级 ──
  static readonly bgBase:          Resource = $r('app.color.bg_base')
  static readonly bgDeep:          Resource = $r('app.color.bg_deep')
  static readonly bgCard:          Resource = $r('app.color.bg_card')
  static readonly bgCardElevated:  Resource = $r('app.color.bg_card_elevated')
  static readonly bgHuaweiBtn:     Resource = $r('app.color.bg_huawei_btn')
  static readonly bgInput:         Resource = $r('app.color.bg_input')
  static readonly bgInputFocused:  Resource = $r('app.color.bg_input_focused')
  static readonly bgGlass:         Resource = $r('app.color.bg_glass')
  static readonly bgOverlay:       Resource = $r('app.color.bg_overlay')

  // ── 文字（5 级）──
  static readonly textPrimary:     Resource = $r('app.color.text_primary')
  static readonly textBody:        Resource = $r('app.color.text_body')
  static readonly textSecondary:   Resource = $r('app.color.text_secondary')
  static readonly textTertiary:    Resource = $r('app.color.text_tertiary')
  static readonly textDisabled:    Resource = $r('app.color.text_disabled')
  static readonly textOnPrimary:   Resource = $r('app.color.text_on_primary')
  static readonly textOnAmber:     Resource = $r('app.color.text_on_amber')

  // ── 边框 / 分割 ──
  static readonly divider:         Resource = $r('app.color.divider')
  static readonly borderDefault:   Resource = $r('app.color.border_default')
  static readonly borderSubtle:    Resource = $r('app.color.border_subtle')
  static readonly borderActive:    Resource = $r('app.color.border_active')

  // ── 光晕 ──
  static readonly glowPrimarySm:   Resource = $r('app.color.glow_primary_sm')
  static readonly glowPrimaryMd:   Resource = $r('app.color.glow_primary_md')
  static readonly glowPrimaryLg:   Resource = $r('app.color.glow_primary_lg')
  static readonly glowAccentSm:    Resource = $r('app.color.glow_accent_sm')
  static readonly glowAmbient:     Resource = $r('app.color.glow_ambient')
  static readonly glowAmbientBottom: Resource = $r('app.color.glow_ambient_bottom')

  // ── 状态色（健康提醒语义）──
  static readonly error:           Resource = $r('app.color.state_error')
  static readonly success:         Resource = $r('app.color.state_success')
  static readonly warning:         Resource = $r('app.color.state_warning')
  static readonly info:            Resource = $r('app.color.state_info')

  // ── 宠物 / 里程碑分类色 ──
  static readonly petDog:          Resource = $r('app.color.pet_dog')
  static readonly petCat:          Resource = $r('app.color.pet_cat')
  static readonly typeTrip:        Resource = $r('app.color.type_trip')
}

export class ThemeRadius {
  static readonly xs:     number = 6
  static readonly sm:     number = 10
  static readonly md:     number = 14
  static readonly input:  number = 14
  static readonly card:   number = 16
  static readonly lg:     number = 20
  static readonly btn:    number = 16
  static readonly pill:   number = 999
}

export class ThemeSize {
  static readonly btnHeight:        number = 52
  static readonly btnHeightSm:      number = 40
  static readonly inputHeight:      number = 50
  static readonly tabBarHeight:     number = 62
  static readonly iconSm:           number = 16
  static readonly iconMd:           number = 22
  static readonly iconLg:           number = 30
}

export class ThemeSpace {
  static readonly xs:     number = 4
  static readonly sm:     number = 8
  static readonly md:     number = 16
  static readonly lg:     number = 24
  static readonly xl:     number = 32
  static readonly xxl:    number = 48
}

export class ThemeFont {
  static readonly h1:           number = 28
  static readonly h2:           number = 22
  static readonly h3:           number = 18
  static readonly subtitle:     number = 16
  static readonly body:         number = 15
  static readonly btn:          number = 16
  static readonly caption:      number = 13
  static readonly footnote:     number = 12
  static readonly micro:        number = 10
}

export class ThemeShadow {
  // ArkUI hex 颜色格式：#AARRGGBB（alpha 在前）
  static readonly buttonPrimary: ShadowOptions = {
    radius: 24,
    color: '#33000000',
    offsetX: 0,
    offsetY: 10
  }
  static readonly buttonPrimaryGlow: ShadowOptions = {
    radius: 28,
    color: '#59F28A3D',
    offsetX: 0,
    offsetY: 0
  }
  static readonly card: ShadowOptions = {
    radius: 28,
    color: '#55000000',
    offsetX: 0,
    offsetY: 10
  }
  static readonly inputFocus: ShadowOptions = {
    radius: 16,
    color: '#1AF28A3D',
    offsetX: 0,
    offsetY: 0
  }
  static readonly buttonAmber: ShadowOptions = {
    radius: 16,
    color: '#26F28A3D',
    offsetX: 0,
    offsetY: 6
  }
}

export class ThemeMotion {
  static readonly fast:       number = 150
  static readonly standard:   number = 280
  static readonly slow:       number = 420
  static readonly pageTrans:  number = 320
}

export class Theme {
  static readonly color    = ThemeColor
  static readonly radius   = ThemeRadius
  static readonly size     = ThemeSize
  static readonly space    = ThemeSpace
  static readonly font     = ThemeFont
  static readonly shadow   = ThemeShadow
  static readonly motion   = ThemeMotion
}
