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
          .borderRadius(Theme.radius.xs)
      } else {
        Column({ space: 4 }) {
          Text('📷').fontSize(24).opacity(0.75)
          Text('示例').fontSize(Theme.font.micro).fontColor(Theme.color.textTertiary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.color.bgCardElevated)
        .borderRadius(Theme.radius.xs)
      }
      if (this.badge.length > 0) {
        Text(this.badge)
          .fontSize(Theme.font.micro)
          .fontColor(Theme.color.textOnPrimary)
          .backgroundColor(Theme.color.primary)
          .borderRadius(3)
          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
          .margin(4)
      }
    }
    .width('100%')
    .aspectRatio(1)
    .onClick(() => { if (this.onTap) this.onTap() })
  }
}
