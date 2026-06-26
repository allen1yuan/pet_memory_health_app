// ============================================================
// PhotoTile —— 相册九宫格单元（图片 + 可选分类角标）
// entry/src/main/ets/components/PhotoTile.ets
// ============================================================

import { Theme } from '../common/Theme'

@Component
export struct PhotoTile {
  @Prop uri: string = ''
  @Prop badge: string = ''
  onTap?: () => void

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      if (this.uri.length > 0) {
        Image(this.uri)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
      } else {
        Column({ space: 4 }) {
          Text('📷').fontSize(24).opacity(0.75)
          Text('示例').fontSize(Theme.font.micro).fontColor(Theme.color.textTertiary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.color.bgCardElevated)
        .borderRadius(Theme.radius.sm)
      }
      if (this.badge.length > 0) {
        Text(this.badge)
          .fontSize(Theme.font.micro)
          .fontColor(Theme.color.textOnPrimary)
          .backgroundColor(Theme.color.primary)
          .borderRadius(Theme.radius.xs)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin(5)
      }
    }
    .width('100%')
    .aspectRatio(1)
    .clip(true)
    .borderRadius(Theme.radius.sm)
    .border({ width: 1, color: Theme.color.borderSubtle })
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
