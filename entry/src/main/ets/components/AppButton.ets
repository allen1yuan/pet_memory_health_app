// ============================================================
// AppButton —— 全 App 唯一合法的按钮组件
// entry/src/main/ets/components/AppButton.ets
//
// 类型：
//   Primary   - 暖橘 CTA：3 段渐变 + 外发光 + 顶高光 + 落地阴影
//   Secondary - 暖深色玻璃 + 微边框（华为登录 = 次要操作）
//   Ghost     - 透明 + 文字色
//   Amber     - 暖琥珀实色
//
// Primary 视觉栈（自下而上）：
//   ① 外层柔光 glow blob（blur 32, 暖橘 35%）
//   ② 主体纵向渐变 #FFC06A → #FF8A3D(55%) → #E85F2A
//   ③ 顶部 1px 内高光 (white 22%)
//   ④ 落地阴影 0 12 28 暖深色
//   ⑤ Pressed 时整体 scale 0.98 + brightness 0.94
//   ⑥ Loading 时左侧 LoadingProgress，文字保持 label
// ============================================================

import { Theme } from '../common/Theme'

export enum AppButtonType {
  Primary = 0,
  Secondary = 1,
  Ghost = 2,
  Amber = 3
}

export enum AppButtonSize {
  Regular = 0,
  Small = 1
}

@Component
export struct AppButton {
  @Prop label: string = ''
  @Prop type: AppButtonType = AppButtonType.Primary
  @Prop btnSize: AppButtonSize = AppButtonSize.Regular
  @Prop disabled: boolean = false
  @Prop loading: boolean = false
  @Prop fullWidth: boolean = true
  @Prop leadingIcon: ResourceStr | null = null
  onTap?: () => void

  @State private pressed: boolean = false

  private isPrimary(): boolean {
    return this.type === AppButtonType.Primary
  }

  private getBgColor(): ResourceColor {
    if (this.disabled) return Theme.color.bgCard
    switch (this.type) {
      case AppButtonType.Primary:   return Theme.color.primary        // 渐变层在上面覆盖，这里兜底
      case AppButtonType.Secondary: return Theme.color.bgHuaweiBtn
      case AppButtonType.Ghost:     return Color.Transparent
      case AppButtonType.Amber:     return Theme.color.ctaAmber
      default:                      return Theme.color.primary
    }
  }

  private getTextColor(): ResourceColor {
    if (this.disabled) return Theme.color.textDisabled
    switch (this.type) {
      case AppButtonType.Primary:   return Theme.color.textOnPrimary
      case AppButtonType.Secondary: return Theme.color.textPrimary
      case AppButtonType.Ghost:     return Theme.color.textSecondary
      case AppButtonType.Amber:     return Theme.color.textOnAmber
      default:                      return Theme.color.textOnPrimary
    }
  }

  private getBorder(): BorderOptions {
    if (this.type === AppButtonType.Secondary) {
      return { width: 1, color: Theme.color.borderSubtle }
    }
    return { width: 0 }
  }

  private getHeight(): number {
    return this.btnSize === AppButtonSize.Small ? Theme.size.btnHeightSm : Theme.size.btnHeight
  }

  build() {
    Stack() {
      // ① 外层柔光 glow（仅 Primary 且非 disabled）
      // 通过比按钮稍大、暖色 + blur 模拟 outer glow
      if (this.isPrimary() && !this.disabled) {
        Column()
          .width('92%')
          .height('70%')
          .borderRadius(Theme.radius.btn)
          .backgroundColor(Theme.color.glowPrimaryLg)
          .blur(32)
          .opacity(this.pressed ? 0.55 : 0.85)
          .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
          .hitTestBehavior(HitTestMode.None)
      }

      // 主体按钮
      Stack() {
        // ② 主体渐变（Primary）/ 实色（其他）
        if (this.isPrimary() && !this.disabled) {
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [
                ['#FFFFC06A', 0.0],
                ['#FFFF8A3D', 0.55],
                ['#FFE85F2A', 1.0]
              ]
            })
            .borderRadius(Theme.radius.btn)
        } else {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(this.getBgColor())
            .borderRadius(Theme.radius.btn)
        }

        // ③ 顶部 1px 内高光（仅 Primary，非 disabled）
        if (this.isPrimary() && !this.disabled) {
          Column()
            .width('86%')
            .height(1)
            .linearGradient({
              angle: 90,
              colors: [
                ['#00FFFFFF', 0],
                ['#38FFFFFF', 0.5],
                ['#00FFFFFF', 1]
              ]
            })
            .position({ x: '7%', y: 1 })
        }

        // 内容层：loading indicator + label
        Row({ space: Theme.space.sm }) {
          if (this.loading) {
            LoadingProgress()
              .width(18)
              .height(18)
              .color(this.getTextColor())
          } else if (this.leadingIcon !== null) {
            Image(this.leadingIcon)
              .width(Theme.size.iconMd)
              .height(Theme.size.iconMd)
              .fillColor(this.getTextColor())
          }
          Text(this.label)
            .fontSize(Theme.font.btn)
            .fontWeight(this.type === AppButtonType.Amber ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.getTextColor())
            .letterSpacing(0)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(this.getHeight())
      .border(this.getBorder())
      .borderRadius(Theme.radius.btn)
      .clip(true)
      // ④ 落地阴影（仅 Primary，非 disabled）
      .shadow(this.isPrimary() && !this.disabled ? Theme.shadow.buttonPrimary : undefined)
      // ⑤ Pressed 反馈：scale + brightness
      .scale({ x: this.pressed ? 0.98 : 1, y: this.pressed ? 0.98 : 1 })
      .brightness(this.pressed ? 0.94 : 1)
      .opacity(this.disabled ? 0.5 : 1)
      .animation({ duration: 120, curve: Curve.EaseOut })
    }
    .width(this.fullWidth ? '100%' : undefined)
    .height(this.getHeight())
    .alignContent(Alignment.Center)
    .onTouch((e: TouchEvent) => {
      if (this.disabled || this.loading) return
      if (e.type === TouchType.Down) this.pressed = true
      else if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressed = false
    })
    .onClick(() => {
      if (!this.disabled && !this.loading && this.onTap) {
        this.onTap()
      }
    })
  }
}
