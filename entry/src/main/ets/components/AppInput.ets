// ============================================================
// AppInput —— 全 App 唯一合法的输入框组件
// entry/src/main/ets/components/AppInput.ets
//
// 视觉规范：
//   背景      暖深棕实色
//   边框      默认暖棕 / focus 暖橘 / error 柔红
//   圆角      24dp
//   高度      56dp
//   文字      暖白输入 / 棕灰 placeholder / 暖橘光标
//   focus     极轻暖橘 outer glow（不影响阅读）
//   error     边框转红 + 下方红色提示
//
// 验证码按钮三态：
//   idle      暖橘 "获取验证码"
//   countdown 棕灰 "60s 后重发"  (传 countdown > 0 进入)
//   disabled  深棕灰 (手机号未填 / loading)
// ============================================================

import { Theme } from '../common/Theme'

export enum AppInputType {
  Text = 0,
  Password = 1,
  PhoneNumber = 2
}

@Component
export struct AppInput {
  @Prop placeholder: string = ''
  @Prop inputType: AppInputType = AppInputType.Text
  @Prop isDisabled: boolean = false
  @Prop trailingAction: string = ''
  @Prop trailingDisabled: boolean = false
  @Prop countdown: number = 0           // > 0 时进入倒计时态
  @Prop errorMsg: string = ''           // 非空时显示 error
  @Link value: string
  onValueChange?: (v: string) => void
  onTrailingTap?: () => void

  @State private isFocused: boolean = false

  private mapInputType(): InputType {
    switch (this.inputType) {
      case AppInputType.Password:    return InputType.Password
      case AppInputType.PhoneNumber: return InputType.PhoneNumber
      default:                       return InputType.Normal
    }
  }

  private hasError(): boolean {
    return this.errorMsg.length > 0
  }

  private getBgColor(): ResourceColor {
    return this.isFocused ? Theme.color.bgInputFocused : Theme.color.bgInput
  }

  private getBorderColor(): ResourceColor {
    if (this.hasError()) return Theme.color.error
    return this.isFocused ? Theme.color.borderActive : Theme.color.borderSubtle
  }

  private getFocusShadow(): ShadowOptions | undefined {
    // focus 态极轻暖橘外发光（10% alpha，不影响阅读）
    if (!this.isFocused || this.hasError()) return undefined
    return {
      radius: 18,
      color: '#1AF28A3D',
      offsetX: 0,
      offsetY: 0
    }
  }

  // 验证码按钮三态色
  private getTrailingColor(): ResourceColor {
    if (this.trailingDisabled) return Theme.color.textDisabled
    if (this.countdown > 0)    return Theme.color.textTertiary
    return Theme.color.primaryLight
  }

  private getTrailingLabel(): string {
    if (this.countdown > 0) return this.countdown + 's 后重发'
    return this.trailingAction
  }

  build() {
    Column({ space: 6 }) {
      // ── 输入框本体 ──
      Stack() {
        // 纯实色背景（不再叠白色透明）
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.getBgColor())
          .borderRadius(Theme.radius.input)

        // 内容
        Row() {
          TextInput({ placeholder: this.placeholder, text: this.value })
            .type(this.mapInputType())
            .placeholderColor(Theme.color.textTertiary)
            .placeholderFont({ size: Theme.font.body })
            .fontColor(Theme.color.textPrimary)
            .fontSize(Theme.font.body)
            .caretColor(Theme.color.primaryLight)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .padding(0)
            .layoutWeight(1)
            .enabled(!this.isDisabled)
            .onChange((v: string) => {
              this.value = v
              if (this.onValueChange) this.onValueChange(v)
            })
            .onFocus(() => { this.isFocused = true })
            .onBlur(() => { this.isFocused = false })

          if (this.trailingAction.length > 0) {
            Divider()
              .vertical(true)
              .height(20)
              .color(Theme.color.divider)
              .margin({ left: Theme.space.md, right: Theme.space.md })
            Text(this.getTrailingLabel())
              .fontSize(Theme.font.caption)
              .fontColor(this.getTrailingColor())
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                if (!this.trailingDisabled && this.countdown <= 0 && this.onTrailingTap) {
                  this.onTrailingTap()
                }
              })
          }
        }
        .width('100%')
        .height('100%')
        .padding({ left: Theme.space.lg, right: Theme.space.lg })
      }
      .width('100%')
      .height(Theme.size.inputHeight)
      .border({ width: 1, color: this.getBorderColor() })
      .borderRadius(Theme.radius.input)
      .shadow(this.getFocusShadow())
      .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })

      // ── Error 提示文案（非空时显示）──
      if (this.hasError()) {
        Row() {
          Text(this.errorMsg)
            .fontSize(Theme.font.footnote)
            .fontColor(Theme.color.error)
            .lineHeight(16)
        }
        .width('100%')
        .padding({ left: Theme.space.md })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
