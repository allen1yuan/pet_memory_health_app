// ============================================================
// AppCard —— 通用卡片容器
// entry/src/main/ets/components/AppCard.ets
//
// 用途：包装任意内容，统一圆角 / 底色 / 阴影 / 内边距
// 变体：default(卡片底) / elevated(浮起+阴影) / glass(玻璃感)
// ============================================================

import { Theme } from '../common/Theme'

export enum AppCardVariant {
  Default = 0,
  Elevated = 1,
  Glass = 2
}

@Component
export struct AppCard {
  @Prop variant: AppCardVariant = AppCardVariant.Default
  @Prop innerPadding: number = Theme.space.md
  @Prop cornerRadius: number = Theme.radius.card
  @BuilderParam content: () => void = this.defaultContent

  @Builder defaultContent() {}

  private getBgColor(): ResourceColor {
    switch (this.variant) {
      case AppCardVariant.Elevated: return Theme.color.bgCardElevated
      case AppCardVariant.Glass:    return Theme.color.bgGlass
      default:                      return Theme.color.bgCard
    }
  }

  private getShadow(): ShadowOptions | undefined {
    return this.variant === AppCardVariant.Elevated ? Theme.shadow.card : undefined
  }

  private getBorder(): BorderOptions {
    return this.variant === AppCardVariant.Glass
      ? { width: 1, color: Theme.color.borderDefault }
      : { width: 0 }
  }

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.innerPadding)
    .backgroundColor(this.getBgColor())
    .borderRadius(this.cornerRadius)
    .border(this.getBorder())
    .shadow(this.getShadow())
  }
}
